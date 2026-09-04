import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/initial_bindings.dart';
import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/core/utils/size_utils.dart';
import 'package:soothifyafrica/app/data/models/user_role.dart';
import 'package:soothifyafrica/app/data/services/language_service.dart';
import 'package:soothifyafrica/app/data/services/session_service.dart';
import 'package:soothifyafrica/app/data/services/theme_service.dart';
import 'package:soothifyafrica/app/routes/app_pages.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';

/// Exercises where splash sends people, which is the one piece of logic that
/// decides what a returning user sees. Every branch is cheap to get wrong and
/// invisible until someone reinstalls.
void main() {
  tearDown(Get.reset);

  // Routes through InitialBindings rather than re-registering each
  // dependency by hand — that duplication drifted out of sync once already
  // (ContentRepository was added to the real binding but not here, and the
  // route smoke test below failed on the Home tab as a result).
  Future<void> bootServices() async {
    await PrefUtils().init();
    Get.put(await SessionService().init(), permanent: true);
    // ThemeService too: main() registers it, and Settings' binding resolves
    // it, so leaving it out here made the route smoke test fail for a reason
    // the app would never hit.
    Get.put(await ThemeService().init(), permanent: true);
    Get.put(await LanguageService().init(), permanent: true);
    InitialBindings().dependencies();
  }

  Future<String?> splashDestination(WidgetTester tester) async {
    await bootServices();

    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          theme: theme,
          getPages: AppPages.pages,
          initialRoute: AppRoutes.splash,
        ),
      ),
    );
    // The splash holds for 600ms before routing. The extra second covers the
    // shell landing case: its IndexedStack builds every tab at once, and the
    // mock repositories behind Home and Discovery answer after a deliberate
    // delay each, which pumpAndSettle does not advance.
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();
    return Get.currentRoute;
  }

  testWidgets('a first launch opens the intro carousel', (tester) async {
    SharedPreferences.setMockInitialValues({});
    expect(await splashDestination(tester), AppRoutes.intro);
  });

  testWidgets('past the intro but signed out goes to sign-up', (tester) async {
    SharedPreferences.setMockInitialValues({'introSeen': true});
    expect(await splashDestination(tester), AppRoutes.signup);
  });

  testWidgets('signed in with the questionnaire unfinished goes to KYC',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'introSeen': true,
      'userRole': UserRole.user.key,
    });
    expect(await splashDestination(tester), AppRoutes.kyc);
  });

  testWidgets('a returning, fully set-up user lands on the home shell',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'introSeen': true,
      'userRole': UserRole.user.key,
      'kycComplete': true,
    });
    expect(await splashDestination(tester), AppRoutes.shell);
  });

  testWidgets('a practitioner goes to their own dashboard', (tester) async {
    SharedPreferences.setMockInitialValues({
      'introSeen': true,
      'userRole': UserRole.practitioner.key,
    });
    expect(await splashDestination(tester), AppRoutes.practitionerDashboard);
  });

  testWidgets('every registered route builds when navigated to',
      (tester) async {
    // Navigates the way the app does, with Get.toNamed. Using initialRoute
    // per page would skip GetX bindings entirely — that is exactly the
    // behaviour that left the splash stranded — so it would fail every
    // GetView for the wrong reason.
    SharedPreferences.setMockInitialValues({});
    await bootServices();

    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          theme: theme,
          getPages: AppPages.pages,
          initialRoute: AppRoutes.splash,
        ),
      ),
    );
    await tester.pump();

    for (final page in AppPages.pages) {
      // Parameterised routes need a value to resolve.
      if (page.name.contains(':') || page.name == AppRoutes.splash) continue;

      Get.toNamed(page.name);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'route ${page.name}');
    }
  });
}
