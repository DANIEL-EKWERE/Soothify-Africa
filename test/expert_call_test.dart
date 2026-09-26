import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/expert_session.dart';
import 'package:soothifyafrica/app/data/repositories/expert_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_expert_repository.dart';
import 'package:soothifyafrica/app/modules/practitioner/availability/controller/slot_editor_controller.dart';
import 'package:soothifyafrica/app/modules/practitioner/availability/expert_slot_editor_screen.dart';
import 'package:soothifyafrica/app/modules/practitioner/call/controller/joining_session_controller.dart';
import 'package:soothifyafrica/app/modules/practitioner/call/joining_session_screen.dart';
import 'package:soothifyafrica/app/modules/practitioner/dashboard/controller/expert_dashboard_controller.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/expert_call_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  DateTime now() => DateTime(2026, 9, 26, 9, 41);

  final session = ExpertSession(
    id: '1',
    clientName: 'Dami',
    service: '1-on-1 Therapy',
    startsAt: DateTime(2026, 9, 28, 10),
    endsAt: DateTime(2026, 9, 28, 11),
  );

  Future<ExpertDashboardController> seedExpert(WidgetTester tester) async {
    Get.put<ExpertRepository>(MockExpertRepository(now: now));
    final dashboard = Get.put(
      ExpertDashboardController(Get.find<ExpertRepository>(), now: now),
    );
    return dashboard;
  }

  group('joining a session', () {
    Future<JoiningSessionController> mount(
      WidgetTester tester, {
      Brightness brightness = Brightness.light,
    }) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.testMode = true;
      final c = Get.put(JoiningSessionController(session: session));
      await pumpScreen(tester, const JoiningSessionScreen(),
          brightness: brightness);
      return c;
    }

    for (final (name, brightness) in [
      ('light', Brightness.light),
      ('dark', Brightness.dark),
    ]) {
      testWidgets('joining session, $name', (tester) async {
        await mount(tester, brightness: brightness);

        await expectLater(find.byType(JoiningSessionScreen),
            matchesGoldenFile('goldens/expert_joining_$name.png'));
      });
    }

    testWidgets('the mic and camera start on and toggle their labels',
        (tester) async {
      final c = await mount(tester);
      expect(c.micOn.value, isTrue);
      expect(c.cameraOn.value, isTrue);
      expect(find.text('Mute Mic'), findsOneWidget);
      expect(find.text('Turn Off Camera'), findsOneWidget);

      c.toggleMic();
      c.toggleCamera();
      await tester.pumpAndSettle();
      expect(find.text('Unmute Mic'), findsOneWidget);
      expect(find.text('Turn On Camera'), findsOneWidget);
    });

    testWidgets('the frame’s typos and its wrong paragraph are not shipped',
        (tester) async {
      await mount(tester);
      // The frame's title reads "Session in Progess".
      expect(find.text('Session in Progress'), findsOneWidget);
      // …and its hint "in a quite space for  the best experience".
      expect(find.textContaining('quiet space for the best'), findsOneWidget);
      // …and its body is the payout flow's, pasted onto a call screen.
      expect(find.textContaining('payout details'), findsNothing);
      expect(find.textContaining('Hold on while we connect you'),
          findsOneWidget);
      // Cancel is the only action the frame gives it.
      expect(find.text('Cancel'), findsOneWidget);
    });
  });

  group('editing an availability window', () {
    Future<SlotEditorController> mount(
      WidgetTester tester, {
      Brightness brightness = Brightness.light,
    }) async {
      useDesignFrame(tester);
      await loadAppFonts();
      final dashboard = await seedExpert(tester);
      await tester.pump(const Duration(milliseconds: 600));
      Get.testMode = true;
      final c = Get.put(
        SlotEditorController(dashboard, slot: dashboard.slots.first),
      );
      await pumpScreen(tester, const ExpertSlotEditorScreen(),
          brightness: brightness);
      return c;
    }

    for (final (name, brightness) in [
      ('light', Brightness.light),
      ('dark', Brightness.dark),
    ]) {
      testWidgets('slot editor, $name', (tester) async {
        await mount(tester, brightness: brightness);

        await expectLater(find.byType(ExpertSlotEditorScreen),
            matchesGoldenFile('goldens/expert_slot_editor_$name.png'));
      });
    }

    testWidgets('the title’s misspelling is corrected', (tester) async {
      await mount(tester);
      // The frame reads "Update Availabilty".
      expect(find.text('Update Availability'), findsOneWidget);
      expect(find.text('Save Availability'), findsOneWidget);
      expect(find.text('Everyday'), findsOneWidget);
    });

    testWidgets('Everyday selects all seven, and clears back to one',
        (tester) async {
      final c = await mount(tester);
      expect(c.everyday, isFalse);

      c.toggleEveryday();
      await tester.pumpAndSettle();
      expect(c.everyday, isTrue);
      expect(c.repeatOn, hasLength(7));

      c.toggleEveryday();
      await tester.pumpAndSettle();
      expect(c.repeatOn, hasLength(1),
          reason: 'clearing falls back to the window’s own day');
    });

    testWidgets('picking a day always includes that weekday', (tester) async {
      final c = await mount(tester);
      c.selectDay(DateTime(2026, 8, 5)); // a Wednesday
      await tester.pumpAndSettle();
      expect(c.day.value, DateTime(2026, 8, 5));
      expect(c.repeatOn, contains(DateTime.wednesday));
      expect(c.month.value, DateTime(2026, 8));
    });

    testWidgets('the window keeps its length — the frame picks one time only',
        (tester) async {
      final c = await mount(tester);
      final was = c.durationMinutes;
      c.setHour(14);
      c.setMinute(30);
      await tester.pumpAndSettle();
      expect(c.from, 14 * 60 + 30);
      expect(c.to - c.from, was);
    });
  });
}
