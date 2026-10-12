import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/expert_session.dart';
import 'package:soothifyafrica/app/data/repositories/expert_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_expert_repository.dart';
import 'package:soothifyafrica/app/modules/practitioner/dashboard/controller/expert_dashboard_controller.dart';
import 'package:soothifyafrica/app/modules/practitioner/notes/controller/session_notes_controller.dart';
import 'package:soothifyafrica/app/modules/practitioner/notes/session_notes_screen.dart';

import 'package:soothifyafrica/app/core/app_export.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/session_notes_test.dart
const _art = [
  'assets/images/notifications/avatar_female.png',
  'assets/images/content/breath_work.png',
];

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
    avatarAsset: 'assets/images/notifications/avatar_female.png',
    startsAt: DateTime(2026, 9, 26, 10),
    endsAt: DateTime(2026, 9, 26, 10, 30),
  );

  Future<SessionNotesController> mount(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put<ExpertRepository>(MockExpertRepository(now: now));
    Get.put(ExpertDashboardController(Get.find<ExpertRepository>(), now: now));

    final c = Get.put(SessionNotesController.forSession(session));
    await pumpScreen(tester, const SessionNotesScreen(),
        brightness: brightness);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await precacheAll(tester, find.byType(SessionNotesScreen), _art);
    return c;
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('session notes, $name', (tester) async {
      await mount(tester, brightness: brightness);

      await expectLater(find.byType(SessionNotesScreen),
          matchesGoldenFile('goldens/session_notes_$name.png'));
    });
  }

  testWidgets('the frame’s own rows, and no call to join', (tester) async {
    await mount(tester);
    expect(find.text('Dami’s session notes'), findsOneWidget);
    // The session is over; the card drops the Join call chip and prints the
    // service and hours where the day would be.
    expect(find.text('Join call'), findsNothing);
    expect(find.text('1-on-1 Therapy * 10:00 AM - 10:30 AM'), findsOneWidget);
    for (final label in ['Good progress', 'Steady', 'Needs follow-up']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Session Summary'), findsOneWidget);
    expect(find.text('Recommendation'), findsOneWidget);
  });

  testWidgets('the recommended content rides under the note', (tester) async {
    final c = await mount(tester);
    expect(c.content.value, isNotNull);
    // The form's own fields are scrollables too, so the list is named.
    await tester.dragUntilVisible(
      find.text('Watch Video'),
      find.byType(ListView),
      Offset(0, -200.v),
    );
    expect(find.text('Guided Breathing for calm'), findsOneWidget);
    expect(find.text('5 min Mindfulness & Stress Relief'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Save'),
      find.byType(ListView),
      Offset(0, -200.v),
    );
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('an outcome is chosen, not assumed', (tester) async {
    final c = await mount(tester);
    expect(c.outcome.value, isNull,
        reason: 'the frame shows one chosen, but that is a clinical '
            'judgement the expert makes');

    await tester.tap(find.text('Good progress'));
    await tester.pumpAndSettle();
    expect(c.outcome.value, SessionOutcome.goodProgress);
  });
}
