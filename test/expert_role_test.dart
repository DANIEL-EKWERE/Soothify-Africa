import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/expert_earnings.dart';
import 'package:soothifyafrica/app/data/models/expert_session.dart';
import 'package:soothifyafrica/app/data/models/expert_tab.dart';
import 'package:soothifyafrica/app/data/repositories/expert_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_expert_repository.dart';
import 'package:soothifyafrica/app/modules/practitioner/dashboard/controller/expert_dashboard_controller.dart';
import 'package:soothifyafrica/app/modules/practitioner/dashboard/expert_dashboard_screen.dart';
import 'package:soothifyafrica/app/modules/practitioner/earnings/expert_earnings_tab.dart';
import 'package:soothifyafrica/app/modules/practitioner/schedule/expert_schedule_tab.dart';
import 'package:soothifyafrica/app/modules/practitioner/shell/controller/expert_shell_controller.dart';
import 'package:soothifyafrica/app/modules/practitioner/shell/expert_shell_screen.dart';
import 'package:soothifyafrica/app/modules/practitioner/widgets/expert_money.dart';
import 'package:soothifyafrica/app/modules/practitioner/widgets/expert_session_card.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/expert_role_test.dart
const _art = [
  'assets/images/home/avatar.png',
  'assets/images/notifications/avatar_female.png',
  'assets/images/notifications/avatar_male.png',
];

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  /// Pinned: every card prints "Today, 10:00 AM" and the payout rows print
  /// dates, so a golden off the real clock goes stale overnight.
  DateTime now() => DateTime(2026, 9, 26, 9, 41);

  Future<ExpertDashboardController> mount(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    Widget screen = const ExpertShellScreen(),
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put<ExpertRepository>(MockExpertRepository(now: now));
    Get.put(ExpertShellController());
    final c = Get.put(
      ExpertDashboardController(Get.find<ExpertRepository>(), now: now),
    );
    await pumpScreen(tester, screen, brightness: brightness);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await precacheAll(tester, find.byType(screen.runtimeType), _art);
    return c;
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('expert dashboard, $name', (tester) async {
      await mount(tester, brightness: brightness);

      await expectLater(find.byType(ExpertShellScreen),
          matchesGoldenFile('goldens/expert_dashboard_$name.png'));
    });

    testWidgets('expert schedule, $name', (tester) async {
      final c = await mount(tester, brightness: brightness);
      Get.find<ExpertShellController>().show(ExpertTab.schedule);
      await tester.pumpAndSettle();
      expect(c.sessions, isNotEmpty);

      await expectLater(find.byType(ExpertShellScreen),
          matchesGoldenFile('goldens/expert_schedule_$name.png'));
    });

    testWidgets('expert earnings, $name', (tester) async {
      await mount(tester, brightness: brightness);
      Get.find<ExpertShellController>().show(ExpertTab.earnings);
      await tester.pumpAndSettle();

      await expectLater(find.byType(ExpertShellScreen),
          matchesGoldenFile('goldens/expert_earnings_$name.png'));
    });
  }

  testWidgets('the dashboard previews three sessions, Schedule lists all',
      (tester) async {
    final c = await mount(tester);
    expect(c.preview, hasLength(3));
    expect(c.sessions.length, greaterThan(3));
    expect(find.byType(ExpertSessionCard), findsNWidgets(3));

    Get.find<ExpertShellController>().show(ExpertTab.schedule);
    await tester.pumpAndSettle();
    expect(find.byType(ExpertScheduleTab), findsOneWidget);
    expect(find.text('Upcoming Session'), findsOneWidget);
  });

  testWidgets('the dashboard carries the frame’s own headings',
      (tester) async {
    await mount(tester);
    expect(find.text('Welcome back,'), findsOneWidget);
    expect(find.text('Baraqhat'), findsOneWidget);
    expect(find.text('You’re making a real difference.'), findsOneWidget);
    expect(find.text('Total Earnings this week'), findsOneWidget);
    expect(find.text('Upcoming Sessions'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Update Availability'), findsOneWidget);
    expect(find.text('Add Session Notes'), findsOneWidget);
  });

  testWidgets('all five tabs are reachable', (tester) async {
    await mount(tester);
    final shell = Get.find<ExpertShellController>();
    for (final tab in ExpertTab.values) {
      shell.show(tab);
      await tester.pumpAndSettle();
      expect(shell.current.value, tab);
    }
    // The earnings tab shows the frame's own labels.
    shell.show(ExpertTab.earnings);
    await tester.pumpAndSettle();
    expect(find.byType(ExpertEarningsTab), findsOneWidget);
    expect(find.text('Available Earnings'), findsOneWidget);
    expect(find.text('Next automatic payout'), findsOneWidget);
    expect(find.text('Payout method'), findsOneWidget);
    expect(find.text('Bank ****1234'), findsOneWidget);
  });

  testWidgets('the dashboard screen mounts on its own', (tester) async {
    await mount(tester, screen: const ExpertDashboardScreen());
    expect(find.byType(ExpertDashboardScreen), findsOneWidget);
  });

  group('the expert nav', () {
    test('has five tabs, and each carries exactly one glyph source', () {
      expect(ExpertTab.values, hasLength(5));
      for (final tab in ExpertTab.values) {
        expect((tab.asset == null) != (tab.icon == null), isTrue,
            reason: '${tab.name} must have an asset or an icon, not both');
      }
    });

    test('reuses the client exports only where the glyph is the same', () {
      // home-smile and face-smile are the client bar's; calendar, wallet and
      // note-edit are the expert bar's own and were not exportable.
      expect(ExpertTab.home.asset, isNotNull);
      expect(ExpertTab.profile.asset, isNotNull);
      for (final tab in [
        ExpertTab.schedule,
        ExpertTab.earnings,
        ExpertTab.notes,
      ]) {
        expect(tab.icon, isNotNull);
      }
    });

    test('is labelled from the frame, not from the layers it was built on',
        () {
      // The design's text layers are still named "Plans" and "Discovery".
      expect(ExpertTab.values.map((t) => t.label),
          ['Home', 'Schedule', 'Earnings', 'Notes', 'Profile']);
    });
  });

  group('money', () {
    test('is naira and grouped, unlike the frame', () {
      // The Earnings frame prints "₦1240" and "$1,105" on the same screen.
      expect(money(1240), '₦1,240');
      expect(money(1105), '₦1,105');
    });
  });

  group('ExpertSession.when', () {
    final base = DateTime(2026, 9, 26, 10);

    ExpertSession at(DateTime start) => ExpertSession(
          id: '1',
          clientName: 'Dami',
          service: '1-on-1 Therapy',
          startsAt: start,
          endsAt: start.add(const Duration(minutes: 30)),
        );

    test('says Today only when it is today', () {
      expect(at(base).when(base), 'Today, 10:00 AM - 10:30 AM');
    });

    test('names tomorrow, and dates anything further out', () {
      expect(at(base.add(const Duration(days: 1))).when(base),
          startsWith('Tomorrow, '));
      expect(at(base.add(const Duration(days: 9))).when(base),
          startsWith('Oct 5, '));
    });

    test('reads noon and midnight as 12, not 0', () {
      expect(at(DateTime(2026, 9, 26, 12)).when(base),
          'Today, 12:00 PM - 12:30 PM');
      expect(at(DateTime(2026, 9, 26)).when(base),
          'Today, 12:00 AM - 12:30 AM');
    });
  });

  test('an availability slot names its day and hours', () {
    final slot = AvailabilitySlot(
      id: '1',
      day: DateTime(2026, 9, 28),
      from: 9 * 60,
      to: 10 * 60,
    );
    expect(slot.weekday, 'Monday');
    expect(slot.date, 'Sep 28');
    expect(slot.range, '9am - 10am');
  });

  test('the earnings sample is the frame’s own figures', () {
    final e = ExpertEarnings.sample(now: now);
    expect(e.available, 1240);
    expect(e.thisWeekSessions, 3);
    expect(e.totalSessions, 5);
    expect(e.payouts, hasLength(4));
    expect(e.nextPayout.weekday, DateTime.friday);
  });
}
