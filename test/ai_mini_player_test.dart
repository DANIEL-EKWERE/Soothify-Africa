import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/environment_vibe.dart';
import 'package:soothifyafrica/app/modules/user/ai_hub/controller/ai_hub_controller.dart';
import 'package:soothifyafrica/app/widgets/ai_mini_player.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/ai_mini_player_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<AiHubController> mount(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
  }) async {
    useDesignFrame(tester);
    disableMotion(tester);
    await loadAppFonts();
    final c = Get.put(AiHubController());
    await pumpScreen(
      tester,
      Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AiMiniPlayer(onExpand: () {}, onClose: () {}),
        ),
      ),
      brightness: brightness,
    );
    return c;
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('ai mini player, $name', (tester) async {
      await mount(tester, brightness: brightness);
      await expectLater(find.byType(AiMiniPlayer),
          matchesGoldenFile('goldens/ai_mini_player_$name.png'));
    });
  }

  testWidgets('it is the frame’s 194x182 panel', (tester) async {
    await mount(tester);
    final box = tester.getSize(find.byType(AiMiniPlayer));
    expect(box.width.round(), AiMiniPlayer.width.round());
    expect(box.height.round(), AiMiniPlayer.height.round());
    expect(find.text('Tap Droplet or Chat to Expand'), findsOneWidget);
  });

  testWidgets('pause stops the scene, and the transport steps the vibe',
      (tester) async {
    final c = await mount(tester);
    expect(c.playing.value, isTrue);

    await tester.tap(find.byIcon(Icons.pause));
    await tester.pumpAndSettle();
    expect(c.playing.value, isFalse);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    // The frame gives the two arrows no job; the vibes are the only sequence
    // the scene has, so they walk it, and they wrap.
    expect(c.vibe.value, EnvironmentVibe.morningMist);
    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pumpAndSettle();
    expect(c.vibe.value, EnvironmentVibe.eveningBreeze);

    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pumpAndSettle();
    expect(c.vibe.value, EnvironmentVibe.sunsetCalm);

    await tester.tap(find.byIcon(Icons.skip_previous));
    await tester.pumpAndSettle();
    expect(c.vibe.value, EnvironmentVibe.eveningBreeze);
  });

  testWidgets('both glyphs are offered: close and expand', (tester) async {
    var expanded = 0;
    var closed = 0;
    useDesignFrame(tester);
    disableMotion(tester);
    await loadAppFonts();
    Get.put(AiHubController());
    await pumpScreen(
      tester,
      Align(
        alignment: Alignment.topRight,
        child: AiMiniPlayer(
          onExpand: () => expanded++,
          onClose: () => closed++,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.open_in_full));
    await tester.pumpAndSettle();
    expect(expanded, 1);

    await tester.tap(find.byIcon(Icons.close_fullscreen));
    await tester.pumpAndSettle();
    expect(closed, 1);
  });
}
