import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/checkin_kind.dart';

/// A daily habit's history and reminder — Figma "Profile/daily meditation"
/// (135:8664), "Profile/daily balance" (135:8707) and the reminder frames
/// (135:8888 onward).
class DailyController extends GetxController {
  DailyController(this.kind, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final CheckinKind kind;
  final DateTime Function() _now;

  late final Rx<DateTime> month =
      DateTime(_now().year, _now().month).obs;

  final Rxn<DateTime> selected = Rxn<DateTime>();

  /// The reminder time. The frames open on 9:00.
  final Rx<TimeOfDay> reminderAt = const TimeOfDay(hour: 9, minute: 0).obs;

  /// Which weekdays carry a reminder — DateTime.monday..sunday.
  final RxSet<int> reminderDays = <int>{}.obs;

  String get title => kind.title;

  /// "Start Daily Pilates & Core" / "Start Daily Stretch & Restore".
  String get startLabel => 'Start ${kind.title}';

  /// The Stretch & Restore frame reuses the Pilates & Core wording verbatim; the habit's own
  /// name is substituted so the empty state does not name the wrong one.
  String get emptyState =>
      'You haven’t completed any ${kind.title}\nyet.';

  /// "Pilates & Core Check-In" / "Stretch & Restore Check-In".
  String get reminderTitle =>
      '${kind.title.replaceFirst('Daily ', '')} Check-In';

  /// The frame prints this under both, naming meditation either way.
  String get reminderBlurb =>
      'Making ${kind.title.replaceFirst('Daily ', '').toLowerCase()} a daily '
      'habit will increase the benefits you get from it.';

  bool get canSetReminder => reminderDays.isNotEmpty;

  void selectDate(DateTime date) => selected.value = date;

  void toggleDay(int weekday) {
    if (!reminderDays.remove(weekday)) reminderDays.add(weekday);
  }

  void setTime(TimeOfDay value) => reminderAt.value = value;

  void openReminder() =>
      Get.toNamed(AppRoutes.dailyReminder, arguments: kind);

  void setReminder() {
    if (!canSetReminder) return;
    // Nothing schedules a notification yet; saying so beats a silent no-op.
    AppFeedback.info('Reminders are not scheduled yet.');
  }
}
