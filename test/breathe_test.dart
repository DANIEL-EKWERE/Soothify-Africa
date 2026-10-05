import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/modules/user/breathe/breathe_screen.dart';
import 'package:soothifyafrica/app/modules/user/breathe/controller/breathe_controller.dart';

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
