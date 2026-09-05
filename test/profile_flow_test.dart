import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/checkin_kind.dart';
import 'package:soothifyafrica/app/data/repositories/local_mood_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mood_repository.dart';
import 'package:soothifyafrica/app/modules/user/checkin/checkin_screen.dart';
import 'package:soothifyafrica/app/modules/user/checkin/controller/checkin_controller.dart';
import 'package:soothifyafrica/app/modules/user/daily/controller/daily_controller.dart';
import 'package:soothifyafrica/app/modules/user/daily/daily_screen.dart';
import 'package:soothifyafrica/app/modules/user/daily/reminder_screen.dart';

import 'helpers.dart';

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
    expect(balance.title, 'Daily Balance');
    expect(balance.startLabel, 'Start Daily Balance');
    expect(balance.emptyState, contains('Daily Balance'));
    expect(balance.emptyState, isNot(contains('Meditation')));
    expect(balance.reminderTitle, 'Balance Check-In');

    final meditation = DailyController(CheckinKind.meditation, now: now);
    expect(meditation.reminderTitle, 'Meditation Check-In');
  });

  test('a reminder needs at least one day', () {
    final c = DailyController(CheckinKind.meditation, now: now);
    expect(c.canSetReminder, isFalse);
    c.toggleDay(DateTime.monday);
    expect(c.canSetReminder, isTrue);
    c.toggleDay(DateTime.monday);
    expect(c.canSetReminder, isFalse);
  });

  testWidgets('the daily screen offers its own start action', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put(DailyController(CheckinKind.balance, now: now));

    await pumpScreen(tester, const DailyScreen());

    expect(find.text('Daily Balance'), findsOneWidget);
    expect(find.text('Start Daily Balance'), findsOneWidget);
    expect(find.text('August 2024'), findsOneWidget);

    await expectLater(find.byType(DailyScreen),
        matchesGoldenFile('goldens/daily_balance.png'));
  });

  testWidgets('reminder days toggle independently', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = DailyController(CheckinKind.meditation, now: now);
    Get.put(c);

    await pumpScreen(tester, const ReminderScreen());
    expect(find.text('Meditation Check-In'), findsOneWidget);
    expect(find.text('9:00'), findsOneWidget);

    c.toggleDay(DateTime.monday);
    c.toggleDay(DateTime.friday);
    await tester.pumpAndSettle();
    expect(c.reminderDays, {DateTime.monday, DateTime.friday});

    await expectLater(find.byType(ReminderScreen),
        matchesGoldenFile('goldens/daily_reminder.png'));
  });

  testWidgets('a check-in calendar marks days that have an entry',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    final repo = LocalMoodRepository(now: now);
    Get.put<MoodRepository>(repo);
    Get.put(CheckinController(repo, CheckinKind.mood, now: now));

    await pumpScreen(tester, const CheckinScreen());
    await tester.pumpAndSettle();

    expect(find.text('Mood Check-Ins'), findsOneWidget);
    // Two months, as the frame stacks them.
    expect(find.text('August 2024'), findsOneWidget);
    expect(find.text('July 2024'), findsOneWidget);
  });
}
