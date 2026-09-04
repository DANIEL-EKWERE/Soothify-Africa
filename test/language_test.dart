import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';

import 'package:soothifyafrica/app/data/models/app_language.dart';
import 'package:soothifyafrica/app/data/models/intro_slide.dart';
import 'package:soothifyafrica/app/data/services/language_service.dart';
import 'package:soothifyafrica/app/modules/auth/language/controller/language_controller.dart';

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  group('LanguageService', () {
    test('starts unchosen and falls back to English', () async {
      final s = await LanguageService().init();
      expect(s.hasChosen, isFalse);
      expect(s.effective, AppLanguage.english);
    });

    test('persists the choice across restarts', () async {
      await (await LanguageService().init()).choose(AppLanguage.pidgin);

      final fresh = await LanguageService().init();
      expect(fresh.selected.value, AppLanguage.pidgin);
      expect(fresh.hasChosen, isTrue);
    });

    test('ignores a language code it no longer recognises', () async {
      PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({'language': 'xx'});
      final s = await LanguageService().init();

      // Must not crash, and must fall back rather than leaving a bad value.
      expect(s.selected.value, isNull);
      expect(s.effective, AppLanguage.english);
    });
  });

  group('LanguageController', () {
    test('Next stays blocked until a language is picked', () async {
      final c = LanguageController(await LanguageService().init())..onInit();
      expect(c.canProceed, isFalse);

      c.select(AppLanguage.pidgin);
      expect(c.canProceed, isTrue);
    });

    test('pre-selects a previous choice', () async {
      final service = await LanguageService().init();
      await service.choose(AppLanguage.pidgin);

      final c = LanguageController(service)..onInit();
      expect(c.selected.value, AppLanguage.pidgin);
    });

    test('offers exactly the two designed languages', () async {
      final c = LanguageController(await LanguageService().init());
      expect(c.languages.map((l) => l.label), ['English', 'Pidgin']);
    });
  });

  group('IntroSlide', () {
    test('carries the three designed panels', () {
      expect(IntroSlide.all, hasLength(3));
      expect(
        IntroSlide.all.map((s) => s.title),
        ['Personalized Therapy', 'Guided Meditation', 'Community'],
      );
    });
  });
}
