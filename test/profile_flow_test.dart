import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/checkin_kind.dart';
import 'package:soothifyafrica/app/data/repositories/kyc_repository.dart';
import 'package:soothifyafrica/app/data/repositories/local_kyc_repository.dart';
import 'package:soothifyafrica/app/data/repositories/local_mood_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mood_repository.dart';
import 'package:soothifyafrica/app/modules/user/checkin/checkin_screen.dart';
import 'package:soothifyafrica/app/modules/user/checkin/controller/checkin_controller.dart';
import 'package:soothifyafrica/app/modules/user/daily/controller/daily_controller.dart';
import 'package:soothifyafrica/app/modules/user/daily/daily_screen.dart';
import 'package:soothifyafrica/app/modules/user/daily/reminder_screen.dart';

import 'helpers.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';
import 'package:soothifyafrica/app/modules/user/daily/daily_start_screen.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/core/utils/size_utils.dart';

/// Regenerate with:
///   flutter test --update-goldens test/profile_flow_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  // Pinned: every one of these screens prints a month or a date.
  DateTime now() => DateTime(2024, 8, 15, 9, 41);

  test('each habit names itself, not the frame it was copied from', () {
    // The Balance frames reuse Meditation's wording verbatim; the empty state
    // and reminder must name the habit you actually opened.
    final balance = DailyController(CheckinKind.balance, now: now);
    expect(balance.title, 'Daily Stretch & Restore');
    expect(balance.startLabel, 'Start Daily Stretch & Restore');
    expect(balance.emptyState, contains('Daily Stretch & Restore'));
    expect(balance.emptyState, isNot(contains('Pilates & Core')));
    expect(balance.reminderTitle, 'Stretch & Restore Check-In');

    final meditation = DailyController(CheckinKind.meditation, now: now);
    expect(meditation.reminderTitle, 'Pilates & Core Check-In');
  });

  test('a reminder needs at least one day', () {
    final c = DailyController(CheckinKind.meditation, now: now);
    expect(c.canSetReminder, isFalse);
    c.toggleDay(DateTime.monday);
    expect(c.canSetReminder, isTrue);
    c.toggleDay(DateTime.monday);
    expect(c.canSetReminder, isFalse);
  });

  for (final (shade, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
  testWidgets('the daily screen offers its own start action, $shade',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put(DailyController(CheckinKind.balance, now: now));

    await pumpScreen(tester, const DailyScreen(), brightness: brightness);

    expect(find.text('Daily Stretch & Restore'), findsOneWidget);
    expect(find.text('Start Daily Stretch & Restore'), findsOneWidget);
    expect(find.text('August 2024'), findsOneWidget);

    await expectLater(find.byType(DailyScreen),
        matchesGoldenFile('goldens/daily_balance_$shade.png'));
  });

  testWidgets('reminder days toggle independently, $shade', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = DailyController(CheckinKind.meditation, now: now);
    Get.put(c);

    await pumpScreen(tester, const ReminderScreen(), brightness: brightness);
    expect(find.text('Pilates & Core Check-In'), findsOneWidget);
    expect(find.text('9:00'), findsOneWidget);

    c.toggleDay(DateTime.monday);
    c.toggleDay(DateTime.friday);
    await tester.pumpAndSettle();
    expect(c.reminderDays, {DateTime.monday, DateTime.friday});

    await expectLater(find.byType(ReminderScreen),
        matchesGoldenFile('goldens/daily_reminder_$shade.png'));
  });
  }

  testWidgets('a check-in calendar marks days that have an entry',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    final repo = LocalMoodRepository(now: now);
    Get.put<MoodRepository>(repo);
    Get.put<KycRepository>(LocalKycRepository());
    Get.put(CheckinController(
      repo,
      Get.find<KycRepository>(),
      CheckinKind.mood,
      now: now,
    ));

    await pumpScreen(tester, const CheckinScreen());
    await tester.pumpAndSettle();

    expect(find.text('Mood Check-Ins'), findsOneWidget);
    // Two months, as the frame stacks them.
    expect(find.text('August 2024'), findsOneWidget);
    expect(find.text('July 2024'), findsOneWidget);
  });

  testWidgets('the daily habit runs start -> reminder', (tester) async {
    useDesignFrame(tester);
    disableMotion(tester);
    await loadAppFonts();
    Get.testMode = true;
    Get.put<ContentRepository>(MockContentRepository());
    Get.put(DailyController(CheckinKind.meditation, now: now));

    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          theme: theme,
          builder: (context, widget) {
            PrimaryColors.syncFrom(context);
            return widget!;
          },
          initialRoute: AppRoutes.daily,
          getPages: [
            GetPage(name: AppRoutes.daily, page: () => const DailyScreen()),
            GetPage(
              name: AppRoutes.dailyStart,
              page: () => const DailyStartScreen(),
            ),
            GetPage(
              name: AppRoutes.dailyReminder,
              page: () => const ReminderScreen(),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The empty state only stands while nothing has been done today.
    expect(find.text('Start Daily Pilates & Core'), findsOneWidget);
    await tester.tap(find.text('Start Daily Pilates & Core'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.dailyStart);
    expect(find.text('Recommended for you'), findsOneWidget);
    expect(find.text('Set Daily Pilates & Core Reminder'), findsOneWidget);
    for (final (label, _) in DailyStartScreen.whens) {
      expect(find.text(label), findsOneWidget);
    }

    await expectLater(find.byType(DailyStartScreen),
        matchesGoldenFile('goldens/daily_start.png'));

    // Any of the three opens the screen that sets the reminder, seeded with
    // that rough hour.
    await tester.tap(find.text('Evening'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.dailyReminder);
    expect(Get.find<DailyController>().reminderAt.value.hour, 19);
  });

  testWidgets('a finished day drops the empty state', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = Get.put(DailyController(CheckinKind.meditation, now: now));

    await pumpScreen(tester, const DailyScreen());
    expect(find.text('Start Daily Pilates & Core'), findsOneWidget);

    c.doneToday.value = true;
    await tester.pumpAndSettle();

    // The invitation is for a day with nothing on it.
    expect(find.text('Start Daily Pilates & Core'), findsNothing);
    expect(find.textContaining('haven’t completed'), findsNothing);
  });
}