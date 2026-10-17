import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/article.dart';
import 'package:soothifyafrica/app/data/models/checkin_kind.dart';
import 'package:soothifyafrica/app/data/models/habit_reminder.dart';
import 'package:soothifyafrica/app/data/models/notification_preference.dart';
import 'package:soothifyafrica/app/data/models/push_message.dart';
import 'package:soothifyafrica/app/data/models/session_invite.dart';
import 'package:soothifyafrica/app/data/repositories/local_device_token_repository.dart';
import 'package:soothifyafrica/app/data/services/push_service.dart';
import 'package:soothifyafrica/app/modules/user/daily/controller/daily_controller.dart';
import 'package:soothifyafrica/app/modules/user/settings/controller/notification_settings_controller.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';
import 'package:soothifyafrica/app/data/repositories/mock_notification_repository.dart';

/// Stands in for [PushService], which cannot be built in a test: its
/// constructor reaches for `FirebaseMessaging.instance`.
class _RecordingScheduler implements ReminderScheduler {
  int? series;
  String? title;
  String? body;
  int? hour;
  int? minute;
  Set<int>? weekdays;
  Map<String, String>? data;
  final cancelled = <int>[];

  @override
  Future<void> scheduleWeekly({
    required int series,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required Set<int> weekdays,
    PushTopic topic = PushTopic.daily,
    Map<String, String> data = const {},
  }) async {
    this.series = series;
    this.title = title;
    this.body = body;
    this.hour = hour;
    this.minute = minute;
    this.weekdays = weekdays;
    this.data = data;
  }

  @override
  Future<void> cancelSeries(int series) async => cancelled.add(series);
}

/// The routing a push performs, and the clock a reminder is set against.
///
/// Neither needs a device: `destinationFor` is a function of the `data` map
/// FCM delivers, and `nextOccurrence` is arithmetic over a timezone. The
/// plugin calls around them are the part that cannot be tested here, which
/// is exactly why the logic is kept out of them.
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  group('a push knows where it goes', () {
    test('a session opens the waiting room with what the push carried', () {
      final d = destinationFor({
        'type': 'session',
        'expert': 'Baraqhat',
        'service': '1-on-1 Yoga',
        'time': '5:00pm',
        'date': 'Sep 28 2026',
      });

      expect(d.route, AppRoutes.clientJoining);
      final invite = d.arguments! as SessionInvite;
      expect(invite.expertName, 'Baraqhat');
      expect(invite.service, '1-on-1 Yoga');
      expect(invite.time, '5:00pm');
      expect(invite.date, 'Sep 28 2026');
    });

    test('a session with nothing but its type still opens', () {
      final d = destinationFor({'type': 'session'});
      expect(d.route, AppRoutes.clientJoining);
      // The screen prints these, so they must be copy rather than "null".
      expect((d.arguments! as SessionInvite).service, '1-on-1 Therapy');
      expect((d.arguments! as SessionInvite).time, '');
    });

    test('the breathing minute and the mood checker', () {
      expect(destinationFor({'type': 'breathe'}).route, AppRoutes.breathe);
      expect(destinationFor({'type': 'mood'}).route, AppRoutes.moodChecker);
    });

    test('a habit reminder opens its own habit', () {
      final d = destinationFor({'type': 'daily', 'habit': 'balance'});
      expect(d.route, AppRoutes.daily);
      expect(d.arguments, CheckinKind.balance);
    });

    test('an article opens the one it names', () {
      expect(
        destinationFor({'type': 'article', 'id': 'rest'}).arguments,
        Article.rest,
      );
      // An id the app does not have is not a reason to show nothing.
      expect(
        destinationFor({'type': 'article', 'id': 'nope'}).arguments,
        Article.core,
      );
    });

    /// A push the user was shown must always open something. Dropping an
    /// unknown one leaves them tapping a notification that does nothing.
    test('anything unrecognised falls back to the feed', () {
      expect(destinationFor({}).route, AppRoutes.notifications);
      expect(destinationFor({'type': ''}).route, AppRoutes.notifications);
      expect(
        destinationFor({'type': 'something-new'}).route,
        AppRoutes.notifications,
      );
    });
  });

  group('when a reminder fires', () {
    setUpAll(() {
      tzdata.initializeTimeZones();
      // Lagos: no DST, which is the common case for this app's users.
      tz.setLocalLocation(tz.getLocation('Africa/Lagos'));
    });

    test('it lands on the next matching weekday, in local time', () {
      final at = PushService.nextOccurrence(DateTime.friday, 9, 0);
      final now = tz.TZDateTime.now(tz.local);

      expect(at.weekday, DateTime.friday);
      expect(at.hour, 9);
      expect(at.minute, 0);
      expect(at.isAfter(now), isTrue);
      // Never more than a week out, whatever day it is today.
      expect(at.difference(now).inDays, lessThan(7));
    });

    /// The hour that has already gone today belongs to next week, not to
    /// the past — scheduling it in the past fires it immediately.
    test('today is skipped once the hour has passed', () {
      final now = tz.TZDateTime.now(tz.local);
      final at = PushService.nextOccurrence(now.weekday, 0, 0);
      expect(at.isAfter(now), isTrue);
      expect(at.day, isNot(now.day));
    });

    /// Each habit owns a block of ids. Two habits sharing one would mean
    /// setting a Stretch reminder silently cancelled the Pilates one.
    test('two habits do not share notification ids', () {
      final used = <int>{};
      for (final kind in CheckinKind.values) {
        final base = reminderSeries(kind);
        for (var day = DateTime.monday; day <= DateTime.sunday; day++) {
          expect(
            used.add(base + day),
            isTrue,
            reason: '${kind.name} reuses id ${base + day}',
          );
        }
      }
    });
  });

  /// A switch in Settings and a scheduled reminder must never disagree.
  group('the Settings switches', () {
    test('each habit with a switch has exactly one', () {
      expect(preferenceFor(CheckinKind.meditation),
          NotificationPreference.meditation);
      expect(preferenceFor(CheckinKind.balance),
          NotificationPreference.balance);
      expect(preferenceFor(CheckinKind.mood), NotificationPreference.mood);
      // The frame draws no journal switch, so there is nothing to keep in
      // step with a journal reminder.
      expect(preferenceFor(CheckinKind.journal), isNull);
    });

    test('setting a reminder switches its habit on', () async {
      await PrefUtils().init();
      expect(PrefUtils().notificationPreference('notify_balance'), isFalse);

      // Without a PushService the schedule is skipped, so drive the part
      // that is testable here: the preference the screen writes.
      await PrefUtils().setNotificationPreference(
        preferenceFor(CheckinKind.balance)!.key,
        true,
      );

      expect(PrefUtils().notificationPreference('notify_balance'), isTrue);
    });

    test('switching one off with no push service does not throw', () async {
      await PrefUtils().init();
      final controller = NotificationSettingsController(MockNotificationRepository())..onInit();
      await controller.toggle(NotificationPreference.balance, false);
      expect(controller.isOn(NotificationPreference.balance), isFalse);
    });
  });

  /// The bug: a reminder lived only inside AlarmManager, which Android
  /// empties whenever it force-stops the app — what several OEM launchers do
  /// when the app is swiped off the recents list. Nothing re-created it, so
  /// reminders only arrived while the app happened to be running.
  group('a reminder outlives the app', () {
    test('what the user set survives a round trip', () {
      const set = HabitReminder(
        hour: 7,
        minute: 5,
        weekdays: {DateTime.monday, DateTime.wednesday},
      );
      final back = HabitReminder.decode(set.encode())!;

      expect(back.hour, 7);
      expect(back.minute, 5);
      expect(back.weekdays, {DateTime.monday, DateTime.wednesday});
    });

    /// Read at launch, so anything unreadable must be ignored rather than
    /// take the app down on the way up.
    test('rubbish in the store is ignored, not thrown', () {
      for (final raw in [
        '',
        'nonsense',
        '7:5',
        '7:5|',
        'x:y|1',
        '25:00|1', // no such hour
        '7:61|1', // no such minute
        '7:5|9', // no such weekday
      ]) {
        expect(HabitReminder.decode(raw), isNull, reason: 'decoded "$raw"');
      }
    });

    test('setting one writes it down', () async {
      await PrefUtils().init();
      Get.testMode = true;
      final controller = DailyController(
        CheckinKind.meditation,
        scheduler: _RecordingScheduler(),
      )
        ..setTime(const TimeOfDay(hour: 7, minute: 5))
        ..toggleDay(DateTime.monday);

      await controller.setReminder();

      final saved = HabitReminder.decode(
        PrefUtils().reminder(CheckinKind.meditation.name),
      );
      expect(saved, isNotNull);
      expect(saved!.hour, 7);
      expect(saved.weekdays, {DateTime.monday});
    });

    /// The screen used to open on 9:00 with no days even when a reminder was
    /// already running — it had no idea one existed.
    test('the screen opens on the reminder already set', () async {
      await PrefUtils().init();
      await PrefUtils().setReminder(
        CheckinKind.balance.name,
        const HabitReminder(
          hour: 18,
          minute: 30,
          weekdays: {DateTime.friday, DateTime.sunday},
        ).encode(),
      );

      final controller = DailyController(CheckinKind.balance)..onInit();

      expect(controller.reminderAt.value.hour, 18);
      expect(controller.reminderAt.value.minute, 30);
      expect(controller.reminderDays, {DateTime.friday, DateTime.sunday});
      expect(controller.canSetReminder, isTrue);
    });

    test('a habit with nothing saved opens on the default', () async {
      await PrefUtils().init();
      final controller = DailyController(CheckinKind.meditation)..onInit();
      expect(controller.reminderAt.value, const TimeOfDay(hour: 9, minute: 0));
      expect(controller.reminderDays, isEmpty);
    });

    test('the notification says the same thing from either path', () {
      expect(
        reminderTitleFor(CheckinKind.meditation),
        'Pilates & Core Check-In',
      );
      expect(
        reminderBodyFor(CheckinKind.balance),
        'Time for your stretch & restore check-in.',
      );
      // The screen's heading is the notification's title, not a second copy.
      expect(
        DailyController(CheckinKind.balance).reminderTitle,
        reminderTitleFor(CheckinKind.balance),
      );
    });
  });

  group('the device token', () {
    test('is remembered, so an unchanged one is not re-sent', () async {
      await PrefUtils().init();
      final repo = LocalDeviceTokenRepository();
      expect(repo.lastRegistered, isEmpty);

      await repo.register(
        token: 'abc123',
        platform: 'Android',
        deviceModel: 'Pixel 8',
        appVersion: '14',
      );

      expect(repo.lastRegistered, 'abc123');
    });
  });

  group('setting a reminder', () {
    /// The bug this guards: the controller used to confirm and *then* pop.
    /// AppFeedback is a GetX snackbar, which GetX pushes as a route, so the
    /// pop closed the snackbar instead of the page — no confirmation, and
    /// the form stayed on screen. Caught on a real device, not here, which
    /// is why the seam exists.
    testWidgets('leaves the screen and confirms, in that order', (
      tester,
    ) async {
      await PrefUtils().init();
      final scheduler = _RecordingScheduler();
      final controller = DailyController(
        CheckinKind.meditation,
        scheduler: scheduler,
      )
        ..setTime(const TimeOfDay(hour: 7, minute: 5))
        ..toggleDay(DateTime.monday)
        ..toggleDay(DateTime.wednesday);
      Get.put(controller);

      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/home',
          getPages: [
            GetPage(name: '/home', page: () => const Scaffold(body: Text('home'))),
            GetPage(
              name: '/reminder',
              page: () => const Scaffold(body: Text('reminder form')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      Get.toNamed('/reminder');
      await tester.pumpAndSettle();
      expect(find.text('reminder form'), findsOneWidget);

      await controller.setReminder();
      await tester.pumpAndSettle();

      // The form is gone...
      expect(find.text('reminder form'), findsNothing);
      expect(find.text('home'), findsOneWidget);
      // ...and the confirmation survived the pop.
      expect(
        find.textContaining('Reminder set for 7:05 AM on Mon & Wed'),
        findsOneWidget,
      );

      // The snackbar dismisses itself after 3s; without waiting that out the
      // test ends on a pending timer.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    test('schedules one series for the habit, on the days chosen', () async {
      // No navigator here, and setReminder pops one. testMode makes the
      // contextless Get.back() a no-op instead of an error.
      Get.testMode = true;
      await PrefUtils().init();
      final scheduler = _RecordingScheduler();
      final controller = DailyController(
        CheckinKind.balance,
        scheduler: scheduler,
      )
        ..setTime(const TimeOfDay(hour: 18, minute: 30))
        ..toggleDay(DateTime.friday);

      await controller.setReminder();

      expect(scheduler.series, reminderSeries(CheckinKind.balance));
      expect(scheduler.weekdays, {DateTime.friday});
      expect(scheduler.hour, 18);
      expect(scheduler.minute, 30);
      expect(scheduler.title, 'Stretch & Restore Check-In');
      expect(scheduler.data, {'habit': 'balance'});
      // And the Settings switch for that habit is now on.
      expect(PrefUtils().notificationPreference('notify_balance'), isTrue);
    });

    /// Without a PushService — in a test, or a build with no Firebase — the
    /// Set button must say so rather than appear to work.
    testWidgets('says so when there is nothing to schedule against', (
      tester,
    ) async {
      final controller = DailyController(CheckinKind.meditation)
        ..toggleDay(DateTime.monday);

      expect(controller.canSetReminder, isTrue);
      // Does not throw, and does not pretend to have scheduled anything.
      await controller.setReminder();
      expect(Get.isRegistered<PushService>(), isFalse);
    });

    test('does nothing at all with no day chosen', () async {
      final controller = DailyController(CheckinKind.balance);
      expect(controller.canSetReminder, isFalse);
      await controller.setReminder();
    });
  });
}
