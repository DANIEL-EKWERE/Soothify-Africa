import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/initial_bindings.dart';
import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/core/utils/size_utils.dart';
import 'package:soothifyafrica/app/data/models/discussion.dart';
import 'package:soothifyafrica/app/data/models/user_role.dart';
import 'package:soothifyafrica/app/data/services/language_service.dart';
import 'package:soothifyafrica/app/data/repositories/kyc_repository.dart';
import 'package:soothifyafrica/app/data/services/session_service.dart';
import 'package:soothifyafrica/app/modules/auth/signup/controller/signup_controller.dart';
import 'package:soothifyafrica/app/data/services/theme_service.dart';
import 'package:soothifyafrica/app/modules/auth/splash/splash_screen.dart';
import 'package:soothifyafrica/app/routes/app_pages.dart';

import 'helpers.dart';
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
    // Landing on the shell mounts the Home assist button, which drifts
    // forever; nothing can settle while it runs.
    disableMotion(tester);
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
    // The splash holds the wordmark, then runs a breathing prompt each — see
    // SplashScreen's durations — so the whole sequence has to elapse before
    // it routes. The extra pumps cover the shell landing case: its
    // IndexedStack builds every tab at once, and the mocks behind them answer
    // after a deliberate delay each, which pumpAndSettle does not advance.
    await tester.pump(SplashScreen.brandHold + const Duration(seconds: 1));
    for (var i = 0; i < SplashScreen.prompts.length; i++) {
      await tester.pump(SplashScreen.breathHold + const Duration(seconds: 1));
    }
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 600));
    }
    await tester.pumpAndSettle();
    return Get.currentRoute;
  }

  testWidgets('a first launch opens the intro carousel', (tester) async {
    SharedPreferences.setMockInitialValues({});
    expect(await splashDestination(tester), AppRoutes.intro);
  });

  testWidgets('a guest past the intro is not sent to sign-up',
      (tester) async {
    // Guest mode: onboarding never asks for an account, so relaunching must
    // not lock a guest out of an app they were already using. With the
    // questionnaire unfinished they land on it, exactly as a signed-in user
    // would.
    SharedPreferences.setMockInitialValues({'introSeen': true});
    expect(await splashDestination(tester), AppRoutes.kyc);
  });

  testWidgets('a guest who finished the questionnaire lands on the shell',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'introSeen': true,
      'kycComplete': true,
    });
    expect(await splashDestination(tester), AppRoutes.shell);
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
    // Two things this test needs before it can judge a layout:
    //   the design frame — at the default 800x600 surface a phone layout
    //   legitimately overflows, which reads as a route defect; and
    //   the real fonts — the fallback face renders markedly wider, so screens
    //   that fit perfectly well report overflows that do not exist.
    // Both bit here: /personalize "overflowed" vertically at 800x600 and
    // /signup horizontally without fonts, and neither is a real defect.
    useDesignFrame(tester);
    disableMotion(tester);
    await loadAppFonts();
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
    // The splash starts its own sequence at initialRoute; letting it finish
    // clears those timers before the loop navigates over the top of it.
    await tester.pump(SplashScreen.brandHold + const Duration(seconds: 1));
    for (var i = 0; i < SplashScreen.prompts.length; i++) {
      await tester.pump(SplashScreen.breathHold + const Duration(seconds: 1));
    }
    await tester.pumpAndSettle();

    // Routes that cannot resolve without an argument. Listed explicitly, and
    // covered instead by the test below, so a route added without arguments
    // is never skipped by accident.
    const needsArguments = {AppRoutes.communityThread};

    for (final page in AppPages.pages) {
      // Parameterised routes need a value to resolve.
      if (page.name.contains(':') ||
          page.name == AppRoutes.splash ||
          needsArguments.contains(page.name)) {
        continue;
      }

      Get.toNamed(page.name);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'route ${page.name}');
    }

    // The argument-taking routes, given one.
    Get.toNamed(
      AppRoutes.communityThread,
      arguments: Discussion(
        id: '1',
        title: 'Depressed and tired',
        body: 'body',
        author: 'Kosin',
        postedAt: DateTime(2024, 7, 15, 8, 41),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull,
        reason: 'route ${AppRoutes.communityThread}');

    // Drain whatever the last routes left running — the shell's mocks chain
    // several delayed calls — so nothing outlives the tree.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 600));
    }
    await tester.pumpAndSettle();
  });

  testWidgets('signing up from Profile does not repeat the questionnaire',
      (tester) async {
    // A guest answers the questionnaire during onboarding, then signs up from
    // Profile later. Sending them back through KYC would make them redo work
    // they had already done — sign-in has always checked, sign-up did not.
    SharedPreferences.setMockInitialValues({
      'introSeen': true,
      'kycComplete': true,
    });
    disableMotion(tester);
    await bootServices();

    final signup = SignupController(
      Get.find<SessionService>(),
      Get.find<KycRepository>(),
    );
    signup.fullname.value = 'Dera';
    signup.email.value = 'dera@example.com';
    signup.password.value = 'Password1';
    signup.confirm.value = 'Password1';

    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => GetMaterialApp(
          theme: theme,
          getPages: AppPages.pages,
          initialRoute: AppRoutes.shell,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    await signup.submit();
    // Landing back on the shell rebuilds every tab, and their mocks chain
    // several 400ms calls each — the whole cascade has to drain before the
    // tree is disposed or the run fails on a pending timer.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 600));
    }
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.shell);
    // And they are no longer a guest.
    expect(Get.find<SessionService>().isGuest, isFalse);
  });
}
