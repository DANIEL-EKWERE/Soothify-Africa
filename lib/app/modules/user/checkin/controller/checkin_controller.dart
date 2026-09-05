import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/checkin_kind.dart';
import '../../../../data/models/mood.dart';
import '../../../../data/repositories/mood_repository.dart';

/// One kind of check-in history — Figma "Profile/mood checkin" (135:8253 for
/// the calendar, 135:8481 for a day's entry).
class CheckinController extends BaseController {
  CheckinController(this._moods, this.kind, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final MoodRepository _moods;
  final CheckinKind kind;
  final DateTime Function() _now;

  /// The months the design lists, newest first.
  late final RxList<DateTime> months = <DateTime>[
    DateTime(_now().year, _now().month),
    DateTime(_now().year, _now().month - 1),
  ].obs;

  final Rxn<DateTime> selected = Rxn<DateTime>();

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
        // Only mood is recorded so far; the other three kinds have nothing
        // behind them yet, so their calendars are honestly empty.
        if (kind != CheckinKind.mood) return;
        final history = await _moods.history();
        marked.assignAll(history.map(
          (e) => DateTime(e.recordedAt.year, e.recordedAt.month,
              e.recordedAt.day),
        ));
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
  }

  void confirm() {
    if (selected.value == null) return;
    if (entry.value == null) {
      AppFeedback.info('Nothing recorded on that day yet.');
    }
  }
}
