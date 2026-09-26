import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/expert_application.dart';
import 'package:soothifyafrica/app/modules/user/expert_application/controller/expert_application_controller.dart';
import 'package:soothifyafrica/app/modules/user/expert_application/expert_application_screen.dart';
import 'package:soothifyafrica/app/modules/user/expert_application/expert_intro_screen.dart';
import 'package:soothifyafrica/app/widgets/expert_form_fields.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/expert_application_test.dart
const _art = ['assets/images/explore/book_expert.jpg'];

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<ExpertApplicationController> mount(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    Widget screen = const ExpertApplicationScreen(),
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = Get.put(ExpertApplicationController());
    await pumpScreen(tester, screen, brightness: brightness);
    return c;
  }

  /// Fills whatever the current step requires, so a test can walk forward.
  void answer(ExpertApplicationController c) {
    switch (c.step.value) {
      case ExpertApplicationStep.profile:
        c.choose(ExpertField.therapist);
        c.name.text = 'Baraqhat Ibrahim';
        c.experience.text = '6';
      case ExpertApplicationStep.languages:
        c.toggleLanguage(ExpertLanguage.english);
      case ExpertApplicationStep.credentials:
        c.licenceNumber.text = 'LT-4471';
    }
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('expert intro, $name', (tester) async {
      await mount(tester,
          brightness: brightness, screen: const ExpertIntroScreen());
      await precacheAll(tester, find.byType(ExpertIntroScreen), _art);

      await expectLater(find.byType(ExpertIntroScreen),
          matchesGoldenFile('goldens/expert_intro_$name.png'));
    });

    for (final step in ExpertApplicationStep.values) {
      testWidgets('expert form ${step.name}, $name', (tester) async {
        final c = await mount(tester, brightness: brightness);
        while (c.step.value != step) {
          answer(c);
          c.next();
          await tester.pumpAndSettle();
        }
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(ExpertApplicationScreen),
          matchesGoldenFile('goldens/expert_form_${step.name}_$name.png'),
        );
      });
    }

    testWidgets('expert application submitted, $name', (tester) async {
      final c = await mount(tester, brightness: brightness);
      for (var i = 0; i < ExpertApplicationStep.values.length; i++) {
        answer(c);
        c.next();
        await tester.pumpAndSettle();
      }

      await expectLater(find.byType(ExpertApplicationScreen),
          matchesGoldenFile('goldens/expert_submitted_$name.png'));
    });
  }

  testWidgets('the intro carries both of the frame’s actions', (tester) async {
    await mount(tester, screen: const ExpertIntroScreen());
    expect(find.text('Join the Soothify Expert Network'), findsOneWidget);
    expect(find.textContaining('English or Pidgin'), findsOneWidget);
    expect(find.text('Start Application'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('a step will not advance until it is answered', (tester) async {
    final c = await mount(tester);
    expect(c.step.value, ExpertApplicationStep.profile);

    // Every "Next" is drawn enabled in the frames, so the rule is the app's:
    // an unanswered question does not advance.
    expect(c.canAdvance, isFalse);
    c.next();
    expect(c.step.value, ExpertApplicationStep.profile);

    answer(c);
    await tester.pumpAndSettle();
    expect(c.canAdvance, isTrue);
    c.next();
    await tester.pumpAndSettle();
    expect(c.step.value, ExpertApplicationStep.languages);
  });

  testWidgets('languages are multi-select; expertise is not', (tester) async {
    final c = await mount(tester);
    c.choose(ExpertField.therapist);
    c.choose(ExpertField.pilates);
    expect(c.field.value, ExpertField.pilates,
        reason: 'one primary area, so the second answer replaces the first');

    c.toggleLanguage(ExpertLanguage.english);
    c.toggleLanguage(ExpertLanguage.pidgin);
    expect(c.languages, ExpertLanguage.values.toSet(),
        reason: 'the question asks which languages, plural');

    c.toggleLanguage(ExpertLanguage.english);
    expect(c.languages, {ExpertLanguage.pidgin});
  });

  testWidgets('back steps through the form rather than leaving it',
      (tester) async {
    final c = await mount(tester);
    answer(c);
    c.next();
    await tester.pumpAndSettle();
    expect(c.step.value, ExpertApplicationStep.languages);

    c.back();
    await tester.pumpAndSettle();
    expect(c.step.value, ExpertApplicationStep.profile);
  });

  testWidgets('both uploads are offered, and neither pretends to work',
      (tester) async {
    final c = await mount(tester);
    for (var i = 0; i < 2; i++) {
      answer(c);
      c.next();
      await tester.pumpAndSettle();
    }
    expect(c.step.value, ExpertApplicationStep.credentials);
    expect(find.byType(ExpertUploadChip), findsNWidgets(2));
    expect(find.text('Add file'), findsNWidgets(2));
    expect(c.attached, isEmpty);
  });

  testWidgets('the acknowledgement is the frame’s own words', (tester) async {
    final c = await mount(tester);
    for (var i = 0; i < ExpertApplicationStep.values.length; i++) {
      answer(c);
      c.next();
      await tester.pumpAndSettle();
    }
    expect(c.submitted.value, isTrue);
    expect(find.text('Application Submitted!'), findsOneWidget);
    expect(find.textContaining('within 24 to 48 hours'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  test('three steps, matching the progress bar the frames draw', () {
    expect(ExpertApplicationStep.values, hasLength(3));
  });
}
