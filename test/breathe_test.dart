import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/modules/user/breathe/breathe_screen.dart';
import 'package:soothifyafrica/app/modules/user/breathe/controller/breathe_controller.dart';
import 'package:soothifyafrica/app/modules/user/breathe/widgets/breath_waves.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/breathe_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<BreatheController> mount(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    final c = Get.put(BreatheController());
    await pumpScreen(tester, const BreatheScreen(), brightness: brightness);
    return c;
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('breathe, $name', (tester) async {
      final c = await mount(tester, brightness: brightness);
      await expectLater(find.byType(BreatheScreen),
          matchesGoldenFile('goldens/breathe_invitation_$name.png'));

      c.phase.value = BreathePhase.active;
      c.remaining.value = 59;
      await tester.pumpAndSettle();
      await expectLater(find.byType(BreatheScreen),
          matchesGoldenFile('goldens/breathe_active_$name.png'));

      c.phase.value = BreathePhase.done;
      c.streak.value = 1;
      await tester.pumpAndSettle();
      await expectLater(find.byType(BreatheScreen),
          matchesGoldenFile('goldens/breathe_done_$name.png'));
    });
  }

  test('the cue lookup splits the cycle 4-2-6', () {
    expect(BreatheCue.cycleSeconds, 12);
    // At the start of each cue, and just before it ends.
    expect(BreatheCue.at(0), (BreatheCue.inhale, 0.0));
    expect(BreatheCue.at(2).$1, BreatheCue.inhale);
    expect(BreatheCue.at(2).$2, closeTo(0.5, 0.001));
    expect(BreatheCue.at(4), (BreatheCue.hold, 0.0));
    expect(BreatheCue.at(6), (BreatheCue.exhale, 0.0));
    expect(BreatheCue.at(9).$2, closeTo(0.5, 0.001));
    // And it wraps, so a second minute reads the same as the first.
    expect(BreatheCue.at(12), (BreatheCue.inhale, 0.0));
    expect(BreatheCue.at(13).$1, BreatheCue.inhale);
  });

  test('the breath fills on the inhale, holds, and empties on the exhale', () {
    expect(BreatheCue.fullnessAt(0), closeTo(0, 0.001));
    // Flutter's easeInOutSine is a cubic approximation: a hair off 0.5.
    expect(BreatheCue.fullnessAt(2), closeTo(0.5, 0.01));
    expect(BreatheCue.fullnessAt(4), closeTo(1, 0.001));
    expect(BreatheCue.fullnessAt(5), closeTo(1, 0.001));
    expect(BreatheCue.fullnessAt(9), closeTo(0.5, 0.01));
    expect(BreatheCue.fullnessAt(11.99), closeTo(0, 0.01));
  });

  // The circle, found by its shape rather than by position in the tree.
  final circle = find.byWidgetPredicate((w) =>
      w is Container &&
      w.decoration is BoxDecoration &&
      (w.decoration! as BoxDecoration).shape == BoxShape.circle);

  final waves = find.byType(BreathWaves);

  testWidgets('the circle either side of the minute, the waves during it',
      (tester) async {
    final c = await mount(tester);

    // Before: the circle, as it always was.
    expect(circle, findsOneWidget);
    expect(waves, findsNothing);

    // During: the waves, and no circle once the crossfade is done.
    c.phase.value = BreathePhase.active;
    c.remaining.value = 59;
    await tester.pumpAndSettle();
    expect(waves, findsOneWidget);
    expect(circle, findsNothing);

    // After: the circle again, untouched.
    c.phase.value = BreathePhase.done;
    c.streak.value = 1;
    await tester.pumpAndSettle();
    expect(circle, findsOneWidget);
    expect(waves, findsNothing);
    expect(tester.getSize(circle).width, closeTo(210, 1),
        reason: 'the circle you finish on is the size the frames draw it');
  });

  testWidgets('the waves rise through the inhale and settle on the exhale',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    final c = Get.put(BreatheController());
    // Motion on: this is the one test that is about the movement itself.
    await pumpScreen(tester, const BreatheScreen(), motion: true);

    BreathWavePainter painter() => tester
        .widget<CustomPaint>(find.descendant(
          of: waves,
          matching: find.byType(CustomPaint),
        ).first)
        .painter! as BreathWavePainter;

    c.start();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    // The inhale starts from the bottom of the breath.
    final early = painter().fullness;
    expect(early, lessThan(0.2));

    // Four seconds in is the top of the inhale.
    await tester.pump(const Duration(milliseconds: 3500));
    final atTop = painter().fullness;
    expect(atTop, greaterThan(0.95));

    // Two more hold it there -- while the lines keep drifting.
    final driftAtTop = painter().drift;
    await tester.pump(const Duration(seconds: 1));
    expect(painter().fullness, closeTo(atTop, 0.05));
    expect(painter().drift, isNot(driftAtTop),
        reason: 'the waves keep moving even during a hold');

    // Then the exhale settles them back down.
    await tester.pump(const Duration(seconds: 6));
    expect(painter().fullness, lessThan(0.1));

    c.close();
  });

  testWidgets('the waves fill the width, edge to edge', (tester) async {
    final c = await mount(tester);
    c.phase.value = BreathePhase.active;
    await tester.pumpAndSettle();
    final screen = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(tester.getSize(waves).width, closeTo(screen, 1));
  });

  testWidgets('the invitation is the frame’s own', (tester) async {
    await mount(tester);
    expect(find.text('Breathe in, breathe out'), findsOneWidget);
    expect(find.text('Find your center today'), findsOneWidget);
    expect(find.textContaining('Take 60 seconds to step away'), findsOneWidget);
    expect(find.text('Start Meditation'), findsOneWidget);
    expect(find.text('Not right now'), findsOneWidget);
  });

  testWidgets('the minute counts down and finishes on the streak',
      (tester) async {
    final c = await mount(tester);

    c.start();
    await tester.pump();
    expect(c.phase.value, BreathePhase.active);
    expect(find.text('1:00'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('0:59'), findsOneWidget);
    expect(find.text(BreatheCue.inhale.label), findsOneWidget);

    // Past the whole minute.
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pumpAndSettle();
    expect(c.phase.value, BreathePhase.done);
    expect(find.text('You did it'), findsOneWidget);
    expect(find.text('Day 1 Streak'), findsOneWidget);
    // The frame's 🔥 is an icon here: neither bundled face has the glyph.
    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
  });

  test('the cue walks the cycle and the clock reads as minutes', () async {
    Get.testMode = true;
    // The controller reads the stored streak on init.
    await PrefUtils().init();
    final c = Get.put(BreatheController());
    c.remaining.value = 60;
    expect(c.clock, '1:00');
    expect(c.cue, BreatheCue.inhale);

    c.remaining.value = 55; // 5s in: past the 4s inhale, into the hold
    expect(c.cue, BreatheCue.hold);

    c.remaining.value = 53; // 7s in: into the exhale
    expect(c.cue, BreatheCue.exhale);

    c.remaining.value = 48; // 12s in: a full cycle has passed
    expect(c.cue, BreatheCue.inhale);

    c.remaining.value = 9;
    expect(c.clock, '0:09');
  });

  test('a streak counts days, not finishes', () async {
    await PrefUtils().init();
    final day = DateTime(2026, 10, 5);

    expect(await PrefUtils().recordBreatheDay(now: day), 1);
    // Twice in one day is still one day.
    expect(await PrefUtils().recordBreatheDay(now: day), 1);
    // The next day continues it.
    expect(
      await PrefUtils().recordBreatheDay(now: day.add(const Duration(days: 1))),
      2,
    );
    // A missed day starts again.
    expect(
      await PrefUtils().recordBreatheDay(now: day.add(const Duration(days: 4))),
      1,
    );
  });
}
