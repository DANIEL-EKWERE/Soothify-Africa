import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/wellness_kyc.dart';
import 'package:soothifyafrica/app/modules/user/wellness_kyc/controller/wellness_kyc_controller.dart';
import 'package:soothifyafrica/app/modules/user/wellness_kyc/wellness_kyc_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/wellness_kyc_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  test('Meditation asks its own questions, not the Schedule set', () {
    // The two intros read identically, so the questions are the only thing
    // distinguishing them — getting this wrong ships Schedule's flow under
    // Meditation's heading.
    expect(WellnessTrack.meditation.steps.first.question,
        'What is your primary reason for seeking meditation guidance?');
    expect(WellnessTrack.schedule.steps.first.question,
        'What type of wellness sessions are you interested in?');
    expect(WellnessTrack.meditation.intro, WellnessTrack.schedule.intro);
    expect(WellnessTrack.meditation.steps.length, 5);
    expect(WellnessTrack.schedule.steps.length, 5);
  });

  test('single- and multi-select behave differently', () {
    final c = WellnessKycController(WellnessTrack.schedule)..begin();

    // Step 1 is multi-select in the design.
    c.choose('Mindfulness');
    c.choose('Anusara');
    expect(c.selected, {'Mindfulness', 'Anusara'});
    c.choose('Anusara');
    expect(c.selected, {'Mindfulness'});

    final single = WellnessKycController(WellnessTrack.meditation)..begin();
    single.choose('Stress relief');
    single.choose('Better sleep');
    expect(single.selected, {'Better sleep'});
  });

  test('Balance asks its own yoga questions and skips the intro', () {
    final b = WellnessTrack.balance;
    expect(b.hasIntro, isFalse);
    expect(b.steps.length, 6);
    expect(b.steps.first.question, 'What’s your level of experience with yoga?');
    // Health conditions are multi-select: the question is plural, and forcing
    // one answer would under-report before a physical class.
    expect(b.steps.last.multiSelect, isTrue);
    // Distinct from the other two tracks.
    expect(b.steps.first.question,
        isNot(WellnessTrack.schedule.steps.first.question));
    expect(b.steps.first.question,
        isNot(WellnessTrack.meditation.steps.first.question));
  });

  test('a track without an intro opens on its first question', () {
    final b = WellnessKycController(WellnessTrack.balance);
    expect(b.onIntro, isFalse);
    expect(b.step.question, 'What’s your level of experience with yoga?');

    final m = WellnessKycController(WellnessTrack.meditation);
    expect(m.onIntro, isTrue);
  });

  test('the last step is labelled Continue, the rest Next', () {
    final c = WellnessKycController(WellnessTrack.meditation)..begin();
    expect(c.actionLabel, 'Next');
    c.index.value = c.track.steps.length - 1;
    expect(c.actionLabel, 'Continue');
  });

  testWidgets('the intro leads into the first question', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    Get.lazyPut(() => WellnessKycController(WellnessTrack.meditation));

    await pumpScreen(tester, const WellnessKycScreen());
    final controller = Get.find<WellnessKycController>();

    expect(controller.onIntro, isTrue);
    expect(find.text('Meditation'), findsOneWidget);
    expect(find.textContaining('Tell us a little about yourself'),
        findsOneWidget);

    // The frame gives the intro no button, so the screen itself advances.
    await tester.tap(find.textContaining('Tell us a little about yourself'));
    await tester.pumpAndSettle();

    expect(controller.onIntro, isFalse);
    expect(
        find.textContaining('primary reason for seeking meditation'),
        findsOneWidget);
  });

  testWidgets('completing it records the track and skips next time',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    final c = WellnessKycController(WellnessTrack.meditation)..begin();
    Get.put(c);

    for (var i = 0; i < c.track.steps.length; i++) {
      c.choose(c.track.steps[i].options.first);
      if (i < c.track.steps.length - 1) await c.next();
    }
    // The final step routes; only the flag matters here.
    await PrefUtils().setWellnessKycDone(c.track.name);

    expect(PrefUtils().wellnessKycDone('meditation'), isTrue);
    // Answering one track must not skip another.
    expect(PrefUtils().wellnessKycDone('schedule'), isFalse);
  });

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('meditation kyc intro, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      await PrefUtils().init();
      Get.lazyPut(() => WellnessKycController(WellnessTrack.meditation));

      await pumpScreen(tester, const WellnessKycScreen(),
          brightness: brightness);

      await expectLater(find.byType(WellnessKycScreen),
          matchesGoldenFile('goldens/wellness_kyc_intro_$name.png'));
    });
  }

  testWidgets('meditation kyc question', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    Get.put(WellnessKycController(WellnessTrack.meditation)..begin());

    await pumpScreen(tester, const WellnessKycScreen());

    await expectLater(find.byType(WellnessKycScreen),
        matchesGoldenFile('goldens/wellness_kyc_question.png'));
  });

  testWidgets('each Next shows the following question', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    final c = WellnessKycController(WellnessTrack.meditation)..begin();
    Get.put(c);

    await pumpScreen(tester, const WellnessKycScreen());

    // Walks the whole questionnaire. A const question widget with no fields
    // is canonicalised, so the subtree never rebuilt and question one
    // repeated forever — stepping through is the only way to catch that.
    for (var i = 0; i < c.track.steps.length; i++) {
      final step = c.track.steps[i];
      expect(find.textContaining(step.question.split(' ').take(4).join(' ')),
          findsOneWidget,
          reason: 'step $i should show its own question');

      c.choose(step.options.first);
      await tester.pumpAndSettle();

      if (i < c.track.steps.length - 1) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        expect(c.index.value, i + 1);
      }
    }
  });
}
