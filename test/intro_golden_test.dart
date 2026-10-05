import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/core/utils/size_utils.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';

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
      Get.put(IntroController(autoAdvance: Duration.zero));

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

  testWidgets('the carousel offers Skip', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await PrefUtils().init();
    Get.put(IntroController(autoAdvance: Duration.zero));

    await pumpScreen(tester, const IntroScreen());
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('Get started leaves the carousel from the first slide',
      (tester) async {
    useDesignFrame(tester);
    disableMotion(tester);
    await loadAppFonts();
    await PrefUtils().init();
    Get.testMode = true;
    final c = Get.put(IntroController(autoAdvance: Duration.zero));

    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          theme: theme,
          builder: (context, widget) {
            PrimaryColors.syncFrom(context);
            return widget!;
          },
          initialRoute: AppRoutes.intro,
          getPages: [
            GetPage(name: AppRoutes.intro, page: () => const IntroScreen()),
            GetPage(
              name: AppRoutes.personalize,
              page: () => const Scaffold(body: Text('personalize')),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // From the first panel, not just the last: the button is the way out of
    // the carousel, not a Next for it.
    expect(c.index.value, 0);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.personalize);
    expect(find.byType(IntroScreen), findsNothing);
    expect(PrefUtils().introSeen(), isTrue);
  });

  testWidgets('Skip on the welcome screen opens the app', (tester) async {
    useDesignFrame(tester);
    disableMotion(tester);
    await loadAppFonts();
    await PrefUtils().init();
    Get.testMode = true;
    Get.put(PersonalizeController());

    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          theme: theme,
          builder: (context, widget) {
            PrimaryColors.syncFrom(context);
            return widget!;
          },
          initialRoute: AppRoutes.personalize,
          getPages: [
            GetPage(
              name: AppRoutes.personalize,
              page: () => const PersonalizeScreen(),
            ),
            GetPage(
              name: AppRoutes.shell,
              page: () => const Scaffold(body: Text('shell')),
            ),
            GetPage(
              name: AppRoutes.kyc,
              page: () => const Scaffold(body: Text('kyc')),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // The app, not the questionnaire: Skip used to swap one set of questions
    // for another.
    expect(Get.currentRoute, AppRoutes.shell);
    expect(find.text('kyc'), findsNothing);
    // And the decision has to survive a relaunch, or resolveStartRoute sends
    // them straight back to the questions they declined.
    expect(PrefUtils().onboardingSkipped(), isTrue);
  });

  test('Skip records that onboarding was declined', () async {
    await PrefUtils().init();
    // Navigation is a no-op here; this is about what Skip persists, and the
    // route table is not mounted in a unit test.
    Get.testMode = true;
    await Get.put(IntroController(autoAdvance: Duration.zero)).skip();

    expect(PrefUtils().introSeen(), isTrue);
    // Kept apart from KYC completion on purpose: skipped means declined, not
    // answered. Without it, resolveStartRoute sends a guest with unfinished
    // KYC straight back into the questionnaire they just skipped.
    expect(PrefUtils().onboardingSkipped(), isTrue);
  });
}
