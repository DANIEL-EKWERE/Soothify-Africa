import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/repositories/kyc_repository.dart';
import 'package:soothifyafrica/app/data/repositories/local_kyc_repository.dart';
import 'package:soothifyafrica/app/data/repositories/local_mood_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mood_repository.dart';
import 'package:soothifyafrica/app/data/services/language_service.dart';
import 'package:soothifyafrica/app/data/services/session_service.dart';
import 'package:soothifyafrica/app/data/services/theme_service.dart';
import 'package:soothifyafrica/app/modules/auth/intro/intro_screen.dart';
import 'package:soothifyafrica/app/modules/auth/splash/splash_screen.dart';
import 'package:soothifyafrica/main.dart';

/// Boots the real [SoothifyApp] widget, not a stand-in.
///
/// Every other test mounts its own GetMaterialApp, which is why a mismatch
/// between the app's navigator mode and the navigation calls in the
/// controllers went unnoticed: the app shipped stuck on the splash while the
/// suite stayed green.
void main() {
  tearDown(Get.reset);

  Future<void> bootServices() async {
    await PrefUtils().init();
    await Get.putAsync(() => SessionService().init(), permanent: true);
    await Get.putAsync(() => ThemeService().init(), permanent: true);
    await Get.putAsync(() => LanguageService().init(), permanent: true);
    Get.put<KycRepository>(LocalKycRepository());
    Get.put<MoodRepository>(LocalMoodRepository());
  }

  testWidgets('the app leaves the splash screen on first launch',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await bootServices();

    await tester.pumpWidget(const SoothifyApp());
    expect(find.byType(SplashScreen), findsOneWidget);

    // The splash holds for 600ms, then routes.
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsNothing,
        reason: 'splash must hand off, not sit there');
    expect(find.byType(IntroScreen), findsOneWidget);
  });
}
