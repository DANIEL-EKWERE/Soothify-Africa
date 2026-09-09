import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/environment_vibe.dart';
import 'package:soothifyafrica/app/modules/user/ai_hub/ai_hub_screen.dart';
import 'package:soothifyafrica/app/modules/user/ai_hub/controller/ai_hub_controller.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/ai_hub_golden_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<AiHubController> mount(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    bool expanded = false,
  }) async {
    useDesignFrame(tester);
    // The scene breathes forever; without this nothing waiting on a still
    // frame ever settles, and the golden would capture a random phase.
    disableMotion(tester);
    await loadAppFonts();
    final controller = Get.put(AiHubController());
    controller.expanded.value = expanded;
    await pumpScreen(tester, const AiHubScreen(), brightness: brightness);
    return controller;
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('ai hub, $name', (tester) async {
      await mount(tester, brightness: brightness);
      await expectLater(find.byType(AiHubScreen),
          matchesGoldenFile('goldens/ai_hub_$name.png'));
    });
  }

  testWidgets('ai hub chat', (tester) async {
    await mount(tester, expanded: true);
    await expectLater(find.byType(AiHubScreen),
        matchesGoldenFile('goldens/ai_hub_chat.png'));
  });

  testWidgets('the panel shows the frame\'s readouts and vibes',
      (tester) async {
    await mount(tester);

    expect(find.text('Tap Droplet or Chat to Expand'), findsOneWidget);
    expect(find.text('Vibe'), findsOneWidget);
    expect(find.text('Breathing Pace'), findsOneWidget);
    expect(find.text('Ease Level'), findsOneWidget);
    expect(find.text('4.7mm'), findsOneWidget);
    expect(find.text('94.2%'), findsOneWidget);
    expect(find.text('Select Environment Vibe'), findsOneWidget);
    for (final v in EnvironmentVibe.values) {
      expect(find.text(v.label), findsAtLeastNWidgets(1));
    }
    expect(find.text('Breathe Together'), findsOneWidget);
  });

  testWidgets('choosing a vibe updates the readout', (tester) async {
    final controller = await mount(tester);

    // "Morning Mist" is both the chosen chip and the Vibe readout.
    expect(find.text('Morning Mist'), findsNWidgets(2));

    await tester.tap(find.text('Sunset Calm'));
    await tester.pumpAndSettle();

    expect(controller.vibe.value, EnvironmentVibe.sunsetCalm);
    expect(find.text('Sunset Calm'), findsNWidgets(2));
    // The Morning Mist chip stays on screen — it is still an option; it is
    // the readout above that moved off it.
    expect(find.text('Morning Mist'), findsOneWidget);
  });

  testWidgets('tapping the scene expands it into the guide', (tester) async {
    final controller = await mount(tester);

    await tester.tap(find.text('Tap Droplet or Chat to Expand'));
    await tester.pumpAndSettle();

    expect(controller.expanded.value, isTrue);
    expect(find.text('Wellness Guide'), findsOneWidget);
    expect(find.textContaining('Welcome to the gentle space'), findsOneWidget);
    expect(find.text('Ask anything...'), findsOneWidget);
  });

  testWidgets('"Breathe Together" opens the guide and starts the scene',
      (tester) async {
    final controller = await mount(tester);
    controller.playing.value = false;

    await tester.tap(find.text('Breathe Together'));
    await tester.pumpAndSettle();

    expect(controller.playing.value, isTrue);
    expect(controller.expanded.value, isTrue);
  });

  testWidgets('sending adds the line and says the guide is not connected',
      (tester) async {
    final controller = await mount(tester, expanded: true);
    final before = controller.messages.length;

    await tester.enterText(find.byType(TextField), 'I feel tense');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();

    expect(controller.messages.length, before + 1);
    expect(controller.messages.last.text, 'I feel tense');
    expect(controller.messages.last.fromGuide, isFalse);

    // Let the snackbar's dismiss timer run out, or the binding reports a
    // pending timer once the tree is gone.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('the guide closes back to the panel', (tester) async {
    final controller = await mount(tester, expanded: true);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(controller.expanded.value, isFalse);
    expect(find.text('Breathe Together'), findsOneWidget);
  });
}
