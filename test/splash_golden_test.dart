import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';


import 'package:soothifyafrica/app/core/utils/size_utils.dart';
import 'package:soothifyafrica/app/modules/auth/splash/splash_screen.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/splash_golden_test.dart
void main() {
  testWidgets('splash matches the design frame', (tester) async {

    tester.view
      ..physicalSize = const Size(figmaDesignWidth * 3, figmaDesignHeight * 3)
      ..devicePixelRatio = 3.0;
    addTearDown(() {
      Get.reset();
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });

    for (final (shade, data) in [('light', theme), ('dark', darkTheme)]) {
      await tester.pumpWidget(
        Sizer(
          builder: (_, _, _) => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: data,
            home: const SplashView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(find.byType(SplashView),
          matchesGoldenFile('goldens/splash_$shade.png'));
    }
  });

  for (var i = 0; i < SplashScreen.prompts.length; i++) {
    testWidgets('splash prompt "${SplashScreen.prompts[i]}"', (tester) async {
      // Without this the prompt draws in the test placeholder face, which is
      // solid blocks — and the golden says nothing about its type.
      await loadAppFonts();
      tester.view
        ..physicalSize = const Size(figmaDesignWidth * 3, figmaDesignHeight * 3)
        ..devicePixelRatio = 3.0;
      addTearDown(() {
        Get.reset();
        tester.view
          ..resetPhysicalSize()
          ..resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        Sizer(
          builder: (_, _, _) => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: SplashView(step: i),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(SplashScreen.prompts[i]), findsOneWidget);
      // The wordmark is gone once a prompt is up.
      expect(find.bySemanticsLabel('Soothify'), findsNothing);

      // Captured, not just asserted: the prompt's type is the designer's own
      // (Nunito Sans Bold 24 on a 24 line) and nothing else on this screen
      // would show it moving.
      await expectLater(find.byType(SplashView),
          matchesGoldenFile('goldens/splash_prompt_$i.png'));
    });
  }

  test('the sequence is the wordmark then a breath in and out', () {
    // The wording is the designer's to set, so this pins the shape rather
    // than the exact copy: two prompts, breathing in before out.
    expect(SplashScreen.prompts, hasLength(2));
    expect(SplashScreen.prompts.first.toLowerCase(), contains('inhale'));
    expect(SplashScreen.prompts.last.toLowerCase(), contains('exhale'));
    expect(SplashScreen.brandHold, const Duration(seconds: 3));
  });

  testWidgets('one prompt clears before the next arrives', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();

    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: const SplashView(step: 0),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(SplashScreen.prompts[0]), findsOneWidget);

    // Swap to the second prompt and stop half way through the transition.
    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: const SplashView(step: 1),
        ),
      ),
    );
    // How visible one of the two words is, 0 when it has left the tree.
    // Scoped to the word itself: the route has fade transitions of its own,
    // and they sit at 1 throughout.
    double shown(String word) {
      final fades = tester.widgetList<FadeTransition>(
        find.ancestor(of: find.text(word), matching: find.byType(FadeTransition)),
      );
      return fades.isEmpty ? 0 : fades.first.opacity.value;
    }

    final first = SplashScreen.prompts[0];
    final second = SplashScreen.prompts[1];

    // The outgoing word is wholly gone by the end of the fade out...
    await tester.pump(const Duration(milliseconds: SplashScreen.fadeOutMs));
    expect(shown(first), lessThan(0.02),
        reason: 'the first word should have cleared completely');
    expect(shown(second), lessThan(0.02));

    // ...and nothing has arrived yet, right up to the end of the gap.
    await tester.pump(const Duration(milliseconds: SplashScreen.gapMs - 20));
    expect(shown(first), lessThan(0.02),
        reason: 'the screen should hold empty for the whole gap');
    expect(shown(second), lessThan(0.02));

    // Then only the new word rises. Overlapping them — AnimatedSwitcher's
    // default, and what mirrored intervals also give — leaves both at half
    // opacity in the same spot, ghosting through each other.
    await tester.pump(const Duration(milliseconds: SplashScreen.fadeOutMs ~/ 2));
    expect(shown(second), greaterThan(0.02));
    expect(shown(first), lessThan(0.02));

    await tester.pumpAndSettle();
    expect(find.text(SplashScreen.prompts[1]), findsOneWidget);
    expect(find.text(SplashScreen.prompts[0]), findsNothing);
  });
}
