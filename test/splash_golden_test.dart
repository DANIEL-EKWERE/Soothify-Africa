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
}
