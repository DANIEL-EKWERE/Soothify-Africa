import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/checkin_kind.dart';
import '../../../../data/models/mood.dart';
import '../../../../data/repositories/kyc_repository.dart';
import '../../../../data/repositories/mood_repository.dart';

/// One kind of check-in history — Figma "Profile/mood checkin" (135:8253 for
/// the calendar, 135:8481 for a day's entry).
class CheckinController extends BaseController {
  CheckinController(
    this._moods,
    this._kyc,
    this.kind, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final MoodRepository _moods;
  final KycRepository _kyc;
  final CheckinKind kind;
  final DateTime Function() _now;

  /// The months the design lists, newest first.
  late final RxList<DateTime> months = <DateTime>[
    DateTime(_now().year, _now().month),
    DateTime(_now().year, _now().month - 1),
  ].obs;

  final Rxn<DateTime> selected = Rxn<DateTime>();

  /// Whose illustration a recorded mood is drawn with — the user's own, from
  /// the KYC gender answer, exactly as the Mood Checker picks it.
  final Rx<MoodFigure> figure = MoodFigure.female.obs;

  /// The calendar gives way to the entry once a day with one is picked; the
  /// header's calendar glyph comes back here.
  final RxBool showingEntry = false.obs;

  /// Days that have an entry, dotted on the calendar.
  final RxSet<DateTime> marked = <DateTime>{}.obs;

  /// The entry for [selected], once a day with one is chosen.
  final Rxn<MoodEntry> entry = Rxn<MoodEntry>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
        final answers = await _kyc.savedAnswers();
        figure.value = MoodFigure.fromKycAnswer(answers['gender']?.firstOrNull);

        // Only mood is recorded so far; the other three kinds have nothing
        // behind them yet, so their calendars are honestly empty.
        if (kind != CheckinKind.mood) return;
        final history = await _moods.history();
        marked.assignAll(history.map(
          (e) => DateTime(e.recordedAt.year, e.recordedAt.month,
              e.recordedAt.day),
        ));
        levels.assignAll({
          for (final e in history)
            DateTime(e.recordedAt.year, e.recordedAt.month, e.recordedAt.day):
                e.level,
        });
      });

  Future<void> selectDate(DateTime date) async {
    selected.value = date;
    if (kind != CheckinKind.mood) {
      entry.value = null;
      return;
    }
    final history = await _moods.history();
    entry.value = history
        .where((e) => DateUtils.isSameDay(e.recordedAt, date))
        .firstOrNull;
    // The frames are two screens: picking a day that has something recorded
    // replaces the calendar with that entry.
    showingEntry.value = entry.value != null;
  }

  void backToCalendar() => showingEntry.value = false;

  /// Every entry, keyed by day, so a calendar cell can be drawn without a
  /// repository call per square.
  final RxMap<DateTime, MoodLevel> levels = <DateTime, MoodLevel>{}.obs;

  /// What a day's circle shows. Days with nothing recorded never ask.
  MoodLevel levelOn(DateTime day) {
    for (final e in levels.entries) {
      if (DateUtils.isSameDay(e.key, day)) return e.value;
    }
    return MoodLevel.good;
  }


}
