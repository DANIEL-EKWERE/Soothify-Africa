import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/image_constant.dart';
import 'package:soothifyafrica/app/data/repositories/kyc_repository.dart';
import 'package:soothifyafrica/app/data/repositories/local_kyc_repository.dart';
import 'package:soothifyafrica/app/data/services/session_service.dart';
import 'package:soothifyafrica/app/modules/auth/signin/controller/signin_controller.dart';
import 'package:soothifyafrica/app/modules/auth/signin/signin_screen.dart';
import 'package:soothifyafrica/app/modules/auth/signup/controller/signup_controller.dart';
import 'package:soothifyafrica/app/modules/auth/signup/signup_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/auth_golden_test.dart
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(Get.reset);

  const icons = [ImageConstant.imgAuthHeaderIcon, ImageConstant.imgGoogle];

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('create account, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.put(await SessionService().init());
      Get.put(SignupController(Get.find<SessionService>()));

      await pumpScreen(tester, const SignupScreen(), brightness: brightness);
      await precacheAll(tester, find.byType(SignupScreen), icons);

      await expectLater(find.byType(SignupScreen),
          matchesGoldenFile('goldens/signup_$name.png'));
    });

    testWidgets('log in, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.put(await SessionService().init());
      Get.put<KycRepository>(LocalKycRepository());
      Get.put(SigninController(
        Get.find<SessionService>(),
        Get.find<KycRepository>(),
      ));

      await pumpScreen(tester, const SigninScreen(), brightness: brightness);
      await precacheAll(tester, find.byType(SigninScreen), icons);

      await expectLater(find.byType(SigninScreen),
          matchesGoldenFile('goldens/signin_$name.png'));
    });

    testWidgets('log in with an error, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.put(await SessionService().init());
      Get.put<KycRepository>(LocalKycRepository());
      final c = Get.put(SigninController(
        Get.find<SessionService>(),
        Get.find<KycRepository>(),
      ));

      await pumpScreen(tester, const SigninScreen(), brightness: brightness);
      await precacheAll(tester, find.byType(SigninScreen), icons);

      c.errorText.value =
          'You entered an incorrect password. Please try again';
      await tester.pumpAndSettle();

      await expectLater(find.byType(SigninScreen),
          matchesGoldenFile('goldens/signin_error_$name.png'));
    });
  }
}
