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
    await tester.pump(SplashScreen.fade ~/ 2);

    // At the mid-point the outgoing word has cleared and the incoming one has
    // not started. Overlapping them — AnimatedSwitcher's default — leaves both
    // at half opacity in the same spot, ghosting through each other.
    final fades = tester
        .widgetList<FadeTransition>(find.byType(FadeTransition))
        .map((f) => f.opacity.value)
        .toList();
    expect(fades.where((o) => o > 0.05 && o < 0.95), isEmpty,
        reason: 'no word should be caught half-faded against another');

    await tester.pumpAndSettle();
    expect(find.text(SplashScreen.prompts[1]), findsOneWidget);
    expect(find.text(SplashScreen.prompts[0]), findsNothing);
  });
}
