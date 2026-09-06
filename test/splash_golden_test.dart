import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';


import 'package:soothifyafrica/app/core/utils/size_utils.dart';
import 'package:soothifyafrica/app/modules/auth/splash/splash_screen.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';

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

    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: const SplashView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
        find.byType(SplashView), matchesGoldenFile('goldens/splash.png'));
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
}
