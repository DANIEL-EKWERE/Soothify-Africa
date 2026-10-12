import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/checkin_kind.dart';
import '../../../../data/models/habit_reminder.dart';
import '../../../../data/services/push_service.dart';

/// A daily habit's history and reminder — Figma "Profile/daily meditation"
/// (135:8664), "Profile/daily balance" (135:8707) and the reminder frames
/// (135:8888 onward).
class DailyController extends GetxController {
  DailyController(this.kind, {DateTime Function()? now, ReminderScheduler? scheduler})
      : _now = now ?? DateTime.now,
        _injectedScheduler = scheduler;

  final CheckinKind kind;
  final DateTime Function() _now;

  /// Supplied only by tests; in the app it comes from [PushService].
  final ReminderScheduler? _injectedScheduler;

  /// Null on a build with no push service — a test, or a device where
  /// Firebase failed to start.
  ReminderScheduler? get _scheduler =>
      _injectedScheduler ??
      (Get.isRegistered<PushService>() ? Get.find<PushService>() : null);

  late final Rx<DateTime> month =
      DateTime(_now().year, _now().month).obs;

  final Rxn<DateTime> selected = Rxn<DateTime>();

  /// The reminder time. The frames open on 9:00.
  final Rx<TimeOfDay> reminderAt = const TimeOfDay(hour: 9, minute: 0).obs;

  /// Which weekdays carry a reminder — DateTime.monday..sunday.
  final RxSet<int> reminderDays = <int>{}.obs;

  String get title => kind.title;

  /// "pilates & core" / "stretch & restore" — the habit without the "Daily".
  String get habit => kind.title.replaceFirst('Daily ', '').toLowerCase();

  /// Whether today's session is already done.
  ///
  /// Nothing records one yet, so this is false and the empty state always
  /// shows; it is the single place to change when history is real.
  final RxBool doneToday = false.obs;

  /// "Start Daily Pilates & Core" / "Start Daily Stretch & Restore".
  String get startLabel => 'Start ${kind.title}';

  /// The Stretch & Restore frame reuses the Pilates & Core wording verbatim; the habit's own
  /// name is substituted so the empty state does not name the wrong one.
  String get emptyState =>
      'You haven’t completed any ${kind.title}\nyet.';

  /// "Pilates & Core Check-In" / "Stretch & Restore Check-In" — the screen's
  /// heading and the notification's title, which must not drift apart.
  String get reminderTitle => reminderTitleFor(kind);

  /// The frame prints this under both, naming meditation either way.
  String get reminderBlurb =>
      'Making ${kind.title.replaceFirst('Daily ', '').toLowerCase()} a daily '
      'habit will increase the benefits you get from it.';

  bool get canSetReminder => reminderDays.isNotEmpty;

  /// The mood recorded on a weekday of the shown week, Sunday first, or null
  /// where nothing was.
  ///
  /// Nothing records one yet, so every day is blank; the strip is there to
  /// be filled, and this is the one place to change when it can be.
  String? moodFor(int weekdayIndex) => null;

  void previousMonth() =>
      month.value = DateTime(month.value.year, month.value.month - 1);

  void nextMonth() =>
      month.value = DateTime(month.value.year, month.value.month + 1);

  void selectDate(DateTime date) => selected.value = date;

  @override
  void onInit() {
    super.onInit();
    // The screen used to open on 9:00 with no days every time, even with a
    // reminder already running — it had no idea one existed.
    //
    // Restoring is a convenience, not a requirement: a screen test that
    // never touches preferences should not have to initialise them just to
    // build this controller.
    if (!PrefUtils.isReady) return;
    final saved = HabitReminder.decode(PrefUtils().reminder(kind.name));
    if (saved == null) return;
    reminderAt.value = TimeOfDay(hour: saved.hour, minute: saved.minute);
    reminderDays.addAll(saved.weekdays);
  }

  void toggleDay(int weekday) {
    if (!reminderDays.remove(weekday)) reminderDays.add(weekday);
  }

  void setTime(TimeOfDay value) => reminderAt.value = value;

  /// "Start Daily …" — the sessions to begin with, and the reminder offer.
  void openStart() => Get.toNamed(AppRoutes.dailyStart, arguments: kind);

  /// Morning / Afternoon / Evening on that screen: it seeds the hour, and
  /// the reminder screen settles the rest.
  void chooseWhen(TimeOfDay at) {
    reminderAt.value = at;
    Get.toNamed(AppRoutes.dailyReminder, arguments: kind);
  }

  void openReminder() =>
      Get.toNamed(AppRoutes.dailyReminder, arguments: kind);

  Future<void> setReminder() async {
    if (!canSetReminder) return;
    final scheduler = _scheduler;
    if (scheduler == null) {
      // Any build without Firebase. The screen still works; it just has
      // nothing to schedule against.
      AppFeedback.info('Reminders are unavailable on this device.');
      return;
    }

    final at = reminderAt.value;
    // Saved first. AlarmManager loses its alarms whenever Android
    // force-stops the app; this is the record that lets [PushService]
    // re-arm them at the next launch.
    await PrefUtils().setReminder(
      kind.name,
      HabitReminder(
        hour: at.hour,
        minute: at.minute,
        weekdays: reminderDays.toSet(),
      ).encode(),
    );

    await scheduler.scheduleWeekly(
      series: reminderSeries(kind),
      title: reminderTitleFor(kind),
      body: reminderBodyFor(kind),
      hour: at.hour,
      minute: at.minute,
      weekdays: reminderDays.toSet(),
      data: {'habit': kind.name},
    );

    // Settings carries a switch per habit. Leaving it off while a reminder
    // is scheduled would show the user a switch that contradicts what the
    // app is about to do.
    final preference = preferenceFor(kind);
    if (preference != null) {
      await PrefUtils().setNotificationPreference(preference.key, true);
    }

    // Leave the screen BEFORE confirming, not after.
    //
    // AppFeedback is a GetX snackbar, and GetX pushes a snackbar as a route.
    // Calling Get.back() after one pops the snackbar instead of the page:
    // the confirmation vanished on the frame it appeared and the user was
    // left sitting on the form, unable to tell whether anything had been
    // saved.
    Get.back();
    AppFeedback.success(
      'Reminder set for ${_clock(at)} on ${_days(reminderDays)}.',
    );
  }

  /// "9:00 AM" — the same 12-hour face the time field shows.
  static String _clock(TimeOfDay at) {
    final h = at.hourOfPeriod == 0 ? 12 : at.hourOfPeriod;
    final m = at.minute.toString().padLeft(2, '0');
    return '$h:$m ${at.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  /// "Mon, Wed & Fri", or "every day" when all seven are on.
  static String _days(Set<int> weekdays) {
    if (weekdays.length == 7) return 'every day';
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final chosen = (weekdays.toList()..sort())
        .map((d) => names[d - 1])
        .toList();
    if (chosen.length == 1) return chosen.single;
    return '${chosen.take(chosen.length - 1).join(', ')} & ${chosen.last}';
  }
}
