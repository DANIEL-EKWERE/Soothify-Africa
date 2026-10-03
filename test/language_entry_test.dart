import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/app_language.dart';
import 'package:soothifyafrica/app/data/services/language_service.dart';
import 'package:soothifyafrica/app/modules/auth/language/controller/language_controller.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';

/// Kept apart from `language_test.dart` on purpose: a single `testWidgets` in
/// a file initialises the widget binding for every plain `test` in it too,
/// and `LanguageService.choose` calls `Get.updateLocale`, which asserts when
/// it tries to schedule a frame outside a test body. Mixing the two broke two
/// passing unit tests.
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  testWidgets('saving from Settings returns there, not into the KYC',
      (tester) async {
    Get.testMode = true;
    final service = await LanguageService().init();
    Get.put(LanguageController(service));

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/settings',
        getPages: [
          GetPage(name: '/settings', page: () => const SizedBox.shrink()),
          GetPage(
            name: AppRoutes.language,
            page: () => const SizedBox.shrink(),
          ),
          GetPage(name: AppRoutes.kyc, page: () => const SizedBox.shrink()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.language, arguments: LanguageEntry.settings);
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.language);

    final c = Get.find<LanguageController>();
    expect(c.fromSettings, isTrue);
    expect(c.entry.action, 'Save Language');
    c.select(AppLanguage.pidgin);
    await c.next();
    await tester.pumpAndSettle();

    // Back where it came from, with the stack intact. It used to finish with
    // `offAllNamed(kyc)` whatever opened it, which dropped the user on the
    // onboarding age question and threw the stack away.
    expect(Get.currentRoute, '/settings');
    expect(service.selected.value, AppLanguage.pidgin);
  });

  testWidgets('the onboarding run still ends at the KYC', (tester) async {
    Get.testMode = true;
    final service = await LanguageService().init();
    Get.put(LanguageController(service));

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.language,
        getPages: [
          GetPage(
            name: AppRoutes.language,
            page: () => const SizedBox.shrink(),
          ),
          GetPage(name: AppRoutes.kyc, page: () => const SizedBox.shrink()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final c = Get.find<LanguageController>();
    expect(c.fromSettings, isFalse);
    expect(c.entry.action, 'Next');
    c.select(AppLanguage.english);
    await c.next();
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.kyc);
  });
}
