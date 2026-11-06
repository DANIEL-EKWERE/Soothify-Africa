import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/app_export.dart';
import 'package:soothifyafrica/app/data/models/studio_partner.dart';
import 'package:soothifyafrica/app/data/repositories/mock_partner_repository.dart';
import 'package:soothifyafrica/app/modules/partner/controller/partner_controller.dart';
import 'package:soothifyafrica/app/modules/partner/controller/partner_ledger_controller.dart';
import 'package:soothifyafrica/app/modules/partner/add_slot_screen.dart';
import 'package:soothifyafrica/app/modules/partner/controller/add_slot_controller.dart';
import 'package:soothifyafrica/app/modules/partner/controller/partner_schedule_controller.dart';
import 'package:soothifyafrica/app/modules/partner/partner_ledger_screen.dart';
import 'package:soothifyafrica/app/modules/partner/check_in_done_screen.dart';
import 'package:soothifyafrica/app/modules/partner/controller/roster_controller.dart';
import 'package:soothifyafrica/app/modules/partner/partner_schedule_screen.dart';
import 'package:soothifyafrica/app/modules/partner/roster_screen.dart';
import 'package:soothifyafrica/app/modules/partner/partner_portal_screen.dart';

import 'helpers.dart';

/// The Studio Partner portal — Figma `4968:32935` (Overview) and
/// `4968:32751` (Active Guest List).
///
/// Repository calls are awaited through `tester.runAsync`: the mock's
/// latency is a real Future.delayed, and testWidgets' fake clock never
/// reaches it — the await simply hangs until the test times out.
///
/// Regenerate with:
///   flutter test --update-goldens test/partner_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
  });
  tearDown(Get.reset);

  DateTime now() => DateTime(2026, 11, 28, 8, 50);

  Future<PartnerController> mount(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    PartnerTab tab = PartnerTab.overview,
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = Get.put(PartnerController(MockPartnerRepository(now: now)));
    await pumpScreen(tester, const PartnerPortalScreen(),
        brightness: brightness);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    c.show(tab);
    await tester.pumpAndSettle();
    return c;
  }

  for (final (shade, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('partner overview, $shade', (tester) async {
      await mount(tester, brightness: brightness);

      await expectLater(find.byType(PartnerPortalScreen),
          matchesGoldenFile('goldens/partner_overview_$shade.png'));
    });

    testWidgets('partner guest list, $shade', (tester) async {
      await mount(tester, brightness: brightness, tab: PartnerTab.guests);

      await expectLater(find.byType(PartnerPortalScreen),
          matchesGoldenFile('goldens/partner_guests_$shade.png'));
    });
  }

  testWidgets('the metrics are the frame’s own figures', (tester) async {
    final c = await mount(tester);
    expect(c.overview.value?.studioName, 'Luma Pilates Studio');
    expect(c.pending, hasLength(2));
    expect(c.overview.value?.confirmedToday, 6);
    expect(c.overview.value?.payoutNaira, 342000);

    expect(find.text('Luma Pilates Studio'), findsOneWidget);
    expect(find.text('Soothify Partner Dashboard'), findsOneWidget);
    expect(find.text('₦342,000'), findsOneWidget);
    expect(find.text('2 requests need your attention today.'), findsOneWidget);
  });

  testWidgets('answering a request takes it out of the feed', (tester) async {
    final c = await mount(tester);
    expect(c.pending, hasLength(2));

    await tester.runAsync(() => c.accept(c.pending.first));
    await tester.pumpAndSettle();

    expect(c.pending, hasLength(1));
    expect(c.requests.first.status, StudioRequestStatus.accepted);
    expect(c.feedSummary, '1 request needs your attention today.');
  });

  testWidgets('the door list counts, filters and searches', (tester) async {
    final c = await mount(tester, tab: PartnerTab.guests);
    expect(c.guests, hasLength(6));
    expect(c.checkedIn, 2);
    expect(c.awaiting, 4);
    expect(c.listSummary, 'All 6 confirmed guests shown · 2 checked in');

    c.choose(GuestFilter.awaiting);
    expect(c.visibleGuests, hasLength(4));

    c.choose(GuestFilter.all);
    c.search('LM-2803');
    expect(c.visibleGuests.single.name, 'Amina B.');

    // The placeholder offers both; a name works too.
    c.search('dami');
    expect(c.visibleGuests.single.code, 'LM-2801');
  });

  testWidgets('checking a guest in moves them, once', (tester) async {
    final c = await mount(tester, tab: PartnerTab.guests);
    final waiting = c.guests.firstWhere(
      (g) => g.arrival == StudioArrival.awaiting,
    );

    await tester.runAsync(() => c.checkIn(waiting));
    await tester.pumpAndSettle();

    expect(c.checkedIn, 3);
    final again = c.guests.firstWhere((g) => g.id == waiting.id);
    expect(again.arrival, StudioArrival.checkedIn);
    expect(again.verifiedAt, isNotNull);

    // A door scanning twice is one arrival.
    await tester.runAsync(() => c.checkIn(again));
    expect(c.checkedIn, 3);
  });

  group('the payout ledger', () {
    Future<PartnerLedgerController> mountLedger(
      WidgetTester tester, {
      Brightness brightness = Brightness.light,
    }) async {
      useDesignFrame(tester);
      await loadAppFonts();
      final c = Get.put(
        PartnerLedgerController(MockPartnerRepository(now: now)),
      );
      await pumpScreen(tester, const PartnerLedgerScreen(),
          brightness: brightness);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      return c;
    }

    for (final (shade, brightness) in [
      ('light', Brightness.light),
      ('dark', Brightness.dark),
    ]) {
      testWidgets('partner ledger, $shade', (tester) async {
        await mountLedger(tester, brightness: brightness);

        await expectLater(find.byType(PartnerLedgerScreen),
            matchesGoldenFile('goldens/partner_ledger_$shade.png'));
      });
    }

    testWidgets('it shows the frame’s figures', (tester) async {
      final c = await mountLedger(tester);
      expect(c.ledger.value?.accruedNaira, 342000);
      expect(c.ledger.value?.lifetimeNaira, 2184500);
      expect(c.ledger.value?.totalEarnings, 24);
      expect(c.ledger.value?.earnings, hasLength(4));

      expect(find.text('Financials & Settlement Hub'), findsOneWidget);
      expect(find.text('₦342,000'), findsOneWidget);
      expect(find.text('₦2,184,500'), findsOneWidget);
      expect(find.text('Showing the latest 4 of 24 earnings'), findsOneWidget);
    });

    testWidgets('only the newest line can be disputed', (tester) async {
      final c = await mountLedger(tester);
      final rows = c.ledger.value!.earnings;
      expect(rows.first.disputable, isTrue);
      expect(rows.skip(1).every((e) => !e.disputable), isTrue,
          reason: 'a settled fortnight is closed');
      expect(find.text('Dispute Check-In'), findsOneWidget);
    });
  });

  group('the master schedule', () {
    Future<PartnerScheduleController> mountSchedule(
      WidgetTester tester, {
      Brightness brightness = Brightness.light,
    }) async {
      useDesignFrame(tester);
      await loadAppFonts();
      final c = Get.put(PartnerScheduleController(
        MockPartnerRepository(now: now),
        now: now,
      ));
      await pumpScreen(tester, const PartnerScheduleScreen(),
          brightness: brightness);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      return c;
    }

    for (final (shade, brightness) in [
      ('light', Brightness.light),
      ('dark', Brightness.dark),
    ]) {
      testWidgets('partner schedule, $shade', (tester) async {
        await mountSchedule(tester, brightness: brightness);

        await expectLater(find.byType(PartnerScheduleScreen),
            matchesGoldenFile('goldens/partner_schedule_$shade.png'));
      });
    }

    testWidgets('the week carries the frame’s eight classes', (tester) async {
      final c = await mountSchedule(tester);
      final week = c.schedule.value!;
      expect(week.classes, hasLength(8));
      expect(week.weekStart.weekday, DateTime.monday);
      // Three of the frame's blocks still have places; the rest are full.
      expect(week.classes.where((s) => !s.isFull), hasLength(3));
      expect(week.slotsOpen, 8);
      expect(week.utilisation, 67);

      expect(find.text('Soothify slot manager'), findsOneWidget);
      expect(find.text('Reformer'), findsWidgets);
    });

    testWidgets('stepping a week reloads it', (tester) async {
      final c = await mountSchedule(tester);
      final first = c.schedule.value!.weekStart;

      await tester.runAsync(c.nextWeek);
      await tester.pumpAndSettle();
      expect(c.schedule.value!.weekStart,
          first.add(const Duration(days: 7)));

      await tester.runAsync(c.previousWeek);
      await tester.pumpAndSettle();
      expect(c.schedule.value!.weekStart, first);
    });
  });

  group('adding a class slot', () {
    Future<AddSlotController> mountSheet(
      WidgetTester tester, {
      Brightness brightness = Brightness.light,
    }) async {
      useDesignFrame(tester);
      await loadAppFonts();
      final c = Get.put(AddSlotController(
        MockPartnerRepository(now: now),
        now: now,
      ));
      await pumpScreen(tester, const AddSlotScreen(), brightness: brightness);
      await tester.pumpAndSettle();
      return c;
    }

    for (final (shade, brightness) in [
      ('light', Brightness.light),
      ('dark', Brightness.dark),
    ]) {
      testWidgets('add slot, $shade', (tester) async {
        await mountSheet(tester, brightness: brightness);

        await expectLater(find.byType(AddSlotScreen),
            matchesGoldenFile('goldens/partner_add_slot_$shade.png'));
      });
    }

    testWidgets('it opens on the frame’s own answers', (tester) async {
      final c = await mountSheet(tester);
      expect(c.category.value, StudioClassCategory.reformer);
      expect(c.spots.value, 3);
      expect(c.allocation, '3 of 8 total class spots reserved');
      expect(c.offPeak.value, isTrue);
      expect(c.recurrence.value, SlotRecurrence.custom);
      expect(c.recurrenceSummary, contains('Repeats Mon, Wed & Fri until'));
    });

    testWidgets('the allocation cannot exceed the room', (tester) async {
      final c = await mountSheet(tester);
      for (var i = 0; i < 20; i++) {
        c.more();
      }
      expect(c.spots.value, AddSlotController.classCapacity,
          reason: 'reserving more places than the room holds is how a '
              'member turns up to a full floor');

      for (var i = 0; i < 20; i++) {
        c.fewer();
      }
      expect(c.spots.value, 0);
    });

    testWidgets('nothing is created until the class is named',
        (tester) async {
      final c = await mountSheet(tester);
      expect(c.canCreate, isFalse);

      c.title.text = 'Sunrise Reformer';
      c.instructor.text = 'Kemi A.';
      c.room.text = 'Studio A';
      c.touch();
      expect(c.canCreate, isTrue);
    });
  });

  group('the door', () {
    Future<RosterController> mountRoster(
      WidgetTester tester, {
      Brightness brightness = Brightness.light,
    }) async {
      useDesignFrame(tester);
      await loadAppFonts();
      final c = Get.put(
        RosterController(MockPartnerRepository(now: now), classId: '1'),
      );
      await pumpScreen(tester, const RosterScreen(), brightness: brightness);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      return c;
    }

    for (final (shade, brightness) in [
      ('light', Brightness.light),
      ('dark', Brightness.dark),
    ]) {
      testWidgets('live roster, $shade', (tester) async {
        await mountRoster(tester, brightness: brightness);

        await expectLater(find.byType(RosterScreen),
            matchesGoldenFile('goldens/partner_roster_$shade.png'));
      });
    }

    testWidgets('it opens on the frame’s class and members', (tester) async {
      final c = await mountRoster(tester);
      final roster = c.roster.value!;
      expect(roster.title, 'Reformer Flow');
      expect(roster.members, hasLength(3));
      expect(roster.verified, 2);
      expect(roster.notArrived, 1);
      expect(roster.offline, isTrue);
      expect(roster.unsynced, 2);
      expect(c.arrivalSummary, '2 checked in · 1 not arrived');

      expect(find.text('Front desk verification'), findsOneWidget);
      expect(find.text('Offline Mode Active'), findsOneWidget);
    });

    testWidgets('a good code admits the member', (tester) async {
      final c = await mountRoster(tester);
      Get.testMode = true;
      c.entryCode.text = 'STH-45C';
      c.touch();
      // Already in, so the desk is told rather than shown a receipt.
      await tester.runAsync(c.verify);
      await tester.pumpAndSettle();
      expect(c.failure.value?.problem, contains('already checked in'));
    });

    testWidgets('an expired code offers provisional entry', (tester) async {
      final c = await mountRoster(tester);
      c.entryCode.text = 'STH-89A';
      c.touch();
      await tester.runAsync(c.verify);
      await tester.pumpAndSettle();

      expect(c.failure.value, isNotNull);
      expect(c.failure.value!.problem, contains('expired'));
      expect(c.failure.value!.member?.name, 'Amina B.');
      expect(find.text('Check-in unsuccessful'), findsOneWidget);
      expect(find.text('Dispute Check in'), findsOneWidget);

      await expectLater(find.byType(RosterScreen),
          matchesGoldenFile('goldens/partner_roster_error.png'));
    });

    testWidgets('granting entry needs a reason, and marks them provisional',
        (tester) async {
      final c = await mountRoster(tester);
      c.entryCode.text = 'STH-89A';
      c.touch();
      await tester.runAsync(c.verify);
      await tester.pumpAndSettle();

      expect(c.canSubmitDispute, isFalse, reason: 'no reason picked yet');
      c.toggleReason(CheckInProblem.code);
      expect(c.canSubmitDispute, isTrue);

      Get.testMode = true;
      await tester.runAsync(c.grantEntry);
      await tester.pumpAndSettle();

      final amina = c.roster.value!.members
          .firstWhere((m) => m.name == 'Amina B.');
      expect(amina.status, StudioVerification.provisional);
      expect(c.granted.value?.name, 'Amina B.');
      expect(c.admittedSummary, '3 admitted · 2 verified · 1 provisional');

      await tester.pumpAndSettle();
      await expectLater(find.byType(RosterScreen),
          matchesGoldenFile('goldens/partner_roster_provisional.png'));
    });

    testWidgets('the receipt names who was admitted', (tester) async {
      final c = await mountRoster(tester);
      final member = c.roster.value!.members.first;
      await pumpScreen(tester, const CheckInDoneScreen());
      await tester.pumpAndSettle();
      expect(member.name, 'Dami A.');
      expect(find.text('Check-in successful'), findsOneWidget);
    });
  });
}
