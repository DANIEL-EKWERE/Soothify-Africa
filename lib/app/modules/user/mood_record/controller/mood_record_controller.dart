import 'package:intl/intl.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/repositories/mood_repository.dart';

/// Backs the post-check-in screen: a short congratulation and the week's
/// streak.
///
/// Figma `135:2056`. This replaced a calendar-style history screen built from
/// an older file — the real design has no month navigation or per-day detail;
/// browsing history lives under Profile instead.
class MoodRecordController extends BaseController {
  MoodRecordController(this._repository, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final MoodRepository _repository;

  /// Overridable so "today" can be pinned in tests — a screen that highlights
  /// the current day drifts out of sync with any golden that captured it.
  final DateTime Function() _now;

  /// One flag per day of the current week, starting Sunday.
  final RxList<bool> completed = List<bool>.filled(7, false).obs;

  /// The design greets by name; empty until there is a profile to read it
  /// from, in which case the headline drops the name rather than inventing one.
  final RxString name = ''.obs;

  List<String> get labels => const ['SUN', 'MON', 'TUE', 'WED', 'THUR', 'FRI', 'SAT'];

  /// DateTime.weekday is 1=Mon..7=Sun; `% 7` puts Sunday at 0.
  int get todayIndex => _now().weekday % 7;

  String get headline =>
      name.value.isEmpty ? 'Nice job today.' : 'Nice job today,\n${name.value}.';

  String get body =>
      'Come back tomorrow, or explore your other recommendations.';

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final today = _now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: todayIndex));

    final entries = await guard(
      () => _repository.between(start, start.add(const Duration(days: 6))),
    );
    if (entries == null) return;

    final flags = List<bool>.filled(7, false);
    for (final e in entries) {
      final i = e.recordedAt.difference(start).inDays;
      if (i >= 0 && i < 7) flags[i] = true;
    }
    completed.assignAll(flags);
  }

  /// Matches the design's only action.
  void returnHome() => Get.offAllNamed(AppRoutes.shell);

  static String debugKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
}
