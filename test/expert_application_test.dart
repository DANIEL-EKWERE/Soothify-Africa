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
const _art = ['assets/images/explore/book_expert.png'];

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  /// Stands in for the system picker, which has no test implementation.
  AttachedDocument? nextPick = const AttachedDocument(
    name: 'certificate.pdf',
    path: '/tmp/certificate.pdf',
    bytes: 240 * 1024,
  );

  Future<ExpertApplicationController> mount(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    Widget screen = const ExpertApplicationScreen(),
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = Get.put(
      ExpertApplicationController(pickDocument: () async => nextPick),
    );
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
        for (final d in ExpertDocument.values) {
          c.attached[d] = const AttachedDocument(
            name: 'doc.pdf',
            path: '/tmp/doc.pdf',
            bytes: 1024,
          );
        }
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
    expect(findSoothify('Join the Soothify Expert Network'), findsOneWidget);
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

  testWidgets('both expertise and languages are multi-select', (tester) async {
    final c = await mount(tester);
    c.choose(ExpertField.therapist);
    c.choose(ExpertField.pilates);
    // "What are your primary areas of expertise?" — a practitioner can be a
    // licensed therapist and a yoga instructor. Choosing a second one used
    // to drop the first.
    expect(c.fields, {ExpertField.therapist, ExpertField.pilates});
    c.choose(ExpertField.pilates);
    expect(c.fields, {ExpertField.therapist}, reason: 'tapping again clears');

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

  /// Walks to the credentials step without filling it in.
  Future<ExpertApplicationController> atCredentials(WidgetTester tester) async {
    final c = await mount(tester);
    for (var i = 0; i < 2; i++) {
      answer(c);
      c.next();
      await tester.pumpAndSettle();
    }
    expect(c.step.value, ExpertApplicationStep.credentials);
    return c;
  }

  testWidgets('both uploads are offered and empty to start', (tester) async {
    final c = await atCredentials(tester);
    expect(find.byType(ExpertUploadChip), findsNWidgets(2));
    expect(find.text('Add file'), findsNWidgets(2));
    expect(c.attached, isEmpty);
  });

  testWidgets('a picked document replaces its chip and is named',
      (tester) async {
    final c = await atCredentials(tester);
    await c.attach(ExpertDocument.certification);
    await tester.pumpAndSettle();

    expect(c.attached[ExpertDocument.certification]?.name, 'certificate.pdf');
    expect(find.text('certificate.pdf'), findsOneWidget);
    expect(find.text('240 KB'), findsOneWidget);
    // One slot filled, one still asking.
    expect(find.text('Add file'), findsOneWidget);

    c.removeAttachment(ExpertDocument.certification);
    await tester.pumpAndSettle();
    expect(find.text('Add file'), findsNWidgets(2));
  });

  testWidgets('cancelling the picker leaves what was already there',
      (tester) async {
    final c = await atCredentials(tester);
    await c.attach(ExpertDocument.identity);
    expect(c.attached, hasLength(1));

    nextPick = null; // the sheet was dismissed
    await c.attach(ExpertDocument.identity);
    expect(c.attached[ExpertDocument.identity]?.name, 'certificate.pdf',
        reason: 'backing out is not the same as removing');

    nextPick = const AttachedDocument(
      name: 'certificate.pdf',
      path: '/tmp/certificate.pdf',
      bytes: 240 * 1024,
    );
  });

  testWidgets('an oversized file is refused, with its size named',
      (tester) async {
    final c = await atCredentials(tester);
    nextPick = const AttachedDocument(
      name: 'scan.pdf',
      path: '/tmp/scan.pdf',
      bytes: 24 * 1024 * 1024,
    );
    await c.attach(ExpertDocument.certification);
    await tester.pump();
    expect(c.attached, isEmpty);
    // The refusal names the file and its size, so it is clear which one and
    // by how much.
    expect(find.textContaining('scan.pdf is 24.0 MB'), findsOneWidget);

    // Let the snackbar's own 3s dismiss timer run out; it outlives the test
    // otherwise. `Get.testMode` does not suppress `rawSnackbar`.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    nextPick = const AttachedDocument(
      name: 'certificate.pdf',
      path: '/tmp/certificate.pdf',
      bytes: 240 * 1024,
    );
  });

  testWidgets('both asterisked uploads are required to finish',
      (tester) async {
    final c = await atCredentials(tester);
    c.licenceNumber.text = 'LT-4471';
    await tester.pumpAndSettle();
    // The frame marks both uploads with an asterisk and nothing else on any
    // step, so these are the one mandatory pair.
    expect(c.canAdvance, isFalse);

    await c.attach(ExpertDocument.certification);
    expect(c.canAdvance, isFalse);

    await c.attach(ExpertDocument.identity);
    expect(c.canAdvance, isTrue);
  });

  group('AttachedDocument', () {
    test('sizes read as a person would write them', () {
      AttachedDocument of(int b) =>
          AttachedDocument(name: 'f', path: '/f', bytes: b);
      expect(of(512).size, '512 B');
      expect(of(2048).size, '2 KB');
      expect(of(3 * 1024 * 1024).size, '3.0 MB');
    });

    test('the limit is this app\'s — the frame gives none', () {
      AttachedDocument of(int b) =>
          AttachedDocument(name: 'f', path: '/f', bytes: b);
      expect(of(AttachedDocument.maxBytes).tooLarge, isFalse);
      expect(of(AttachedDocument.maxBytes + 1).tooLarge, isTrue);
    });
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
