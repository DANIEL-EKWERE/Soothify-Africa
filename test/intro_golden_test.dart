import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';

import 'package:soothifyafrica/app/data/models/app_language.dart';
import 'package:soothifyafrica/app/data/models/intro_slide.dart';
import 'package:soothifyafrica/app/data/services/language_service.dart';
import 'package:soothifyafrica/app/modules/auth/intro/controller/intro_controller.dart';
import 'package:soothifyafrica/app/modules/auth/intro/intro_screen.dart';
import 'package:soothifyafrica/app/modules/auth/language/controller/language_controller.dart';
import 'package:soothifyafrica/app/modules/auth/language/language_screen.dart';
import 'package:soothifyafrica/app/modules/auth/personalize/controller/personalize_controller.dart';
import 'package:soothifyafrica/app/modules/auth/personalize/personalize_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/intro_golden_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('intro carousel, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.put(IntroController());

      await pumpScreen(tester, const IntroScreen(), brightness: brightness);
      await precacheAll(tester, find.byType(IntroScreen),
          IntroSlide.all.map((s) => s.assetPath));

      await expectLater(find.byType(IntroScreen),
          matchesGoldenFile('goldens/intro_$name.png'));
    });

    testWidgets('personalize, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.put(PersonalizeController());

      await pumpScreen(tester, const PersonalizeScreen(),
          brightness: brightness);
      await precacheAll(tester, find.byType(PersonalizeScreen),
          const ['assets/images/onboarding/personalize.png']);

      await expectLater(find.byType(PersonalizeScreen),
          matchesGoldenFile('goldens/personalize_$name.png'));
    });

    testWidgets('language, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.put(await LanguageService().init());
      final c = Get.put(LanguageController(Get.find<LanguageService>()));

      await pumpScreen(tester, const LanguageScreen(), brightness: brightness);

      // Untouched: Next dimmed.
      await expectLater(find.byType(LanguageScreen),
          matchesGoldenFile('goldens/language_$name.png'));

      c.select(AppLanguage.english);
      await tester.pumpAndSettle();
      await expectLater(find.byType(LanguageScreen),
          matchesGoldenFile('goldens/language_selected_$name.png'));
    });
  }
}
