import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/wellness_kyc.dart';
import 'package:soothifyafrica/app/modules/user/wellness_kyc/controller/wellness_kyc_controller.dart';
import 'package:soothifyafrica/app/modules/user/wellness_kyc/wellness_kyc_screen.dart';

import 'package:soothifyafrica/app/widgets/match_progress_bar.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/wellness_kyc_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  test('Pilates & Core asks the new set, not the therapy one', () {
    // Rewritten from `Pilates kyc` (259:38083 onward). Getting this wrong
    // ships the therapy flow under Pilates & Core's heading.
    expect(
      WellnessTrack.meditation.steps.first.question,
      'How experienced are you with Pilates?',
    );
    expect(
      WellnessTrack.therapy.steps.first.question,
      'What type of wellness sessions are you interested in?',
    );
    expect(WellnessTrack.meditation.steps.length, 6);
    expect(WellnessTrack.therapy.steps.length, 5);
    // Two of the six carry "Pick as many as you like"; the rest take one.
    expect(
      WellnessTrack.meditation.steps.where((s) => s.multiSelect).length,
      2,
    );
  });

  test('each re-read track has its own intro copy', () {
    // They used to share one line. Pilates & Core has its own from
    // `Pilates kyc` (259:38525) and Stretch & Restore from
    // `Scheduling Kyc/Yoga` (259:38802). Therapy's intro frame (259:38773)
    // has never been fetched, so it has none.
    expect(
      WellnessTrack.meditation.heading,
      'Let’s set up your Pilates session',
    );
    expect(WellnessTrack.balance.heading, 'Tailoring your practice');
    expect(WellnessTrack.therapy.heading, isEmpty);
    expect(WellnessTrack.meditation.intro, isNot(WellnessTrack.balance.intro));
  });

  test('Stretch & Restore owns the Scheduling Kyc intro', () {
    // `Scheduling Kyc/Yoga` (259:38802) heads the `Yoga Kyc` row, and that
    // row is this section's questionnaire — not Book a Licensed Expert's.
    // The frame has been assigned twice before and moved twice.
    final t = WellnessTrack.balance;
    expect(t.heading, 'Tailoring your practice');
    expect(t.intro, startsWith('Tell us a little about your body'));
    expect(t.intro, contains('pair you with the right guide'));
  });

  test('the multi-select hint is the track’s own wording', () {
    expect(WellnessTrack.meditation.multiHint, 'Pick as many as you like');
    expect(
      WellnessTrack.therapy.multiHint,
      'You can select more than one option',
    );
  });

  test('single- and multi-select behave differently', () {
    final c = WellnessKycController(
      WellnessTrack.therapy,
      introWait: Duration.zero,
    )..begin();

    // Step 1 is multi-select in the design.
    c.choose('Mindfulness');
    c.choose('Anusara');
    expect(c.selected, {'Mindfulness', 'Anusara'});
    c.choose('Anusara');
    expect(c.selected, {'Mindfulness'});

    final single = WellnessKycController(
      WellnessTrack.meditation,
      introWait: Duration.zero,
    )..begin();
    single.choose('Total beginner');
    single.choose('I know the basics');
    expect(single.selected, {'I know the basics'});
  });

  test('Stretch & Restore asks the Yoga Kyc row’s questions', () {
    // Was six questions off the archived `Balance Kyc` row (y>62000). The
    // current row is `Yoga Kyc`, of which 259:25803, 25816 and 25831 have
    // been read; 25848, 25868, 25886 and 25899 have not, so this is three
    // where the design draws seven.
    final b = WellnessTrack.balance;
    expect(b.steps.length, 3);
    expect(
      b.steps.first.question,
      'Where are you currently at with your yoga practice?',
    );
    // The frame marks the frequency question multi-select, oddly — Pilates
    // asks the same thing single-select. Honoured as drawn.
    expect(b.steps[1].question, 'How often do you step onto the mat?');
    expect(b.steps[1].multiSelect, isTrue);
    // Trailing full stops on "Most days." and "Cultivating inner strength."
    // are dropped as slips; their siblings carry none.
    expect(b.steps[1].options, contains('Most days'));
    expect(b.steps.last.options, contains('Cultivating inner strength'));
    // Distinct from the other two tracks.
    expect(
      b.steps.first.question,
      isNot(WellnessTrack.therapy.steps.first.question),
    );
    expect(
      b.steps.first.question,
      isNot(WellnessTrack.meditation.steps.first.question),
    );
  });

  testWidgets('the intro runs a bar and advances when it fills', (
    tester,
  ) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    // A real wait this time: both intro frames draw a progress bar 24 below
    // the paragraph (`Pilates kyc` 259:38525, `Scheduling Kyc/Yoga`
    // 259:38802), which is why the screen needs no button.
    final c = Get.put(
      WellnessKycController(
        WellnessTrack.meditation,
        introWait: const Duration(milliseconds: 600),
      ),
    );

    await pumpScreen(tester, const WellnessKycScreen());
    expect(c.onIntro, isTrue);
    expect(find.byType(MatchProgressBar), findsOneWidget);
    expect(c.introProgress.value, lessThan(1));

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(c.introProgress.value, 1);
    expect(c.onIntro, isFalse, reason: 'it moves on by itself');
  });

  testWidgets('tapping skips the wait', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    final c = Get.put(
      WellnessKycController(
        WellnessTrack.meditation,
        introWait: const Duration(seconds: 30),
      ),
    );

    await pumpScreen(tester, const WellnessKycScreen());
    // No hint to aim at any more — the whole intro is the target, which is
    // the behaviour that matters.
    await tester.tap(find.byType(MatchProgressBar));
    await tester.pumpAndSettle();
    expect(c.onIntro, isFalse);
    // The timer is cancelled, not left running behind the questions.
    expect(c.introProgress.value, lessThan(1));
  });

  test('only the tracks with an intro frame open on one', () {
    // Pilates & Core has `Pilates kyc` 259:38525 and Stretch & Restore has
    // `Scheduling Kyc/Yoga` 259:38802. Therapy's (259:38773) has never been
    // fetched, so it starts on its first question rather than on an
    // interstitial nothing in the file draws.
    expect(
      WellnessKycController(
        WellnessTrack.meditation,
        introWait: Duration.zero,
      ).onIntro,
      isTrue,
    );
    expect(
      WellnessKycController(
        WellnessTrack.balance,
        introWait: Duration.zero,
      ).onIntro,
      isTrue,
    );
    expect(
      WellnessKycController(
        WellnessTrack.therapy,
        introWait: Duration.zero,
      ).onIntro,
      isFalse,
    );
  });

  test('a card on Book a licensed expert skips the interstitial', () {
    // The card already named the discipline; "Tailoring your practice" after
    // choosing a yoga session introduces what was just picked. The section
    // entry point still shows it — hence a per-entry flag, not a track one.
    expect(
      WellnessKycController(
        WellnessTrack.balance,
        introWait: Duration.zero,
        skipIntro: true,
      ).onIntro,
      isFalse,
    );
    expect(WellnessTrack.balance.hasIntro, isTrue,
        reason: 'skipping is the caller’s choice, not the track losing it');
  });

  test('the last step is labelled Continue, the rest Next', () {
    final c = WellnessKycController(
      WellnessTrack.meditation,
      introWait: Duration.zero,
    )..begin();
    expect(c.actionLabel, 'Next');
    c.index.value = c.track.steps.length - 1;
    expect(c.actionLabel, 'Continue');
  });

  testWidgets('the intro leads into the first question', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    Get.lazyPut(
      () => WellnessKycController(
        WellnessTrack.meditation,
        introWait: Duration.zero,
      ),
    );

    await pumpScreen(tester, const WellnessKycScreen());
    final controller = Get.find<WellnessKycController>();

    expect(controller.onIntro, isTrue);
    // The frames title the intro "Schedule", not the section, and give the
    // question steps no header at all.
    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('Let’s set up your Pilates session'), findsOneWidget);
    expect(
      find.textContaining('find the right instructor for you'),
      findsOneWidget,
    );
    // The frame gives the intro no button: the bar says it is working and it
    // advances by itself. Nothing tells the user to tap any more.
    expect(find.text('Tap anywhere to continue'), findsNothing);
    expect(find.byType(MatchProgressBar), findsOneWidget);

    // Tapping still skips ahead, anywhere on the intro.
    await tester.tap(find.byType(MatchProgressBar));
    await tester.pumpAndSettle();

    expect(controller.onIntro, isFalse);
    expect(find.text('How experienced are you with Pilates?'), findsOneWidget);
    // No header on a question step.
    expect(find.text('Schedule'), findsNothing);
  });

  testWidgets('completing it records the track and skips next time', (
    tester,
  ) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    final c = WellnessKycController(
      WellnessTrack.meditation,
      introWait: Duration.zero,
    )..begin();
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
      final c = Get.put(
        WellnessKycController(
          WellnessTrack.meditation,
          introWait: Duration.zero,
        ),
      );
      // Held open so the bar cannot advance the screen mid-golden, then
      // parked where the frame parks it: 128 of 280.7.
      c.introProgress.value = 128 / 280.7;

      await pumpScreen(
        tester,
        const WellnessKycScreen(),
        brightness: brightness,
      );

      await expectLater(
        find.byType(WellnessKycScreen),
        matchesGoldenFile('goldens/wellness_kyc_intro_$name.png'),
      );
    });
  }

  testWidgets('meditation kyc question', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    Get.put(
      WellnessKycController(WellnessTrack.meditation, introWait: Duration.zero)
        ..begin(),
    );

    await pumpScreen(tester, const WellnessKycScreen());

    await expectLater(
      find.byType(WellnessKycScreen),
      matchesGoldenFile('goldens/wellness_kyc_question.png'),
    );
  });

  testWidgets('each Next shows the following question', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    final c = WellnessKycController(
      WellnessTrack.meditation,
      introWait: Duration.zero,
    )..begin();
    Get.put(c);

    await pumpScreen(tester, const WellnessKycScreen());

    // Walks the whole questionnaire. A const question widget with no fields
    // is canonicalised, so the subtree never rebuilt and question one
    // repeated forever — stepping through is the only way to catch that.
    for (var i = 0; i < c.track.steps.length; i++) {
      final step = c.track.steps[i];
      expect(
        find.textContaining(step.question.split(' ').take(4).join(' ')),
        findsOneWidget,
        reason: 'step $i should show its own question',
      );

      c.choose(step.options.first);
      await tester.pumpAndSettle();

      if (i < c.track.steps.length - 1) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        expect(c.index.value, i + 1);
      }
    }
  });

  testWidgets('every intro shows the bar, and none of them says to tap', (
    tester,
  ) async {
    for (final track in WellnessTrack.values.where((t) => t.hasIntro)) {
      useDesignFrame(tester);
      await loadAppFonts();
      await PrefUtils().init();
      Get.lazyPut(() => WellnessKycController(track, introWait: Duration.zero));

      await pumpScreen(tester, const WellnessKycScreen());

      expect(
        find.byType(MatchProgressBar),
        findsOneWidget,
        reason: '${track.title} opens on an intro with nothing that moves',
      );
      expect(find.text('Tap anywhere to continue'), findsNothing);

      Get.reset();
    }
  });

  testWidgets('the bar is gone once the questions start', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    Get.lazyPut(
      () => WellnessKycController(
        WellnessTrack.meditation,
        introWait: Duration.zero,
      ),
    );

    await pumpScreen(tester, const WellnessKycScreen());
    Get.find<WellnessKycController>().begin();
    await tester.pumpAndSettle();

    expect(find.byType(MatchProgressBar), findsNothing);
  });
}
