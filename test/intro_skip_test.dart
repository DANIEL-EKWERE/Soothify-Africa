import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/core/utils/size_utils.dart';
import 'package:soothifyafrica/app/modules/auth/intro/controller/intro_controller.dart';
import 'package:soothifyafrica/app/modules/auth/intro/intro_screen.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';

import 'helpers.dart';

/// Kept apart from `intro_golden_test.dart`: that file's Skip test runs
/// without a route table and so can only check what Skip persists. This one
/// mounts one, because the reported fault was that Skip did not land
/// anywhere.
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  testWidgets('Skip lands on the shell, and nothing is left behind it',
      (tester) async {
    useDesignFrame(tester);
    disableMotion(tester);
    await loadAppFonts();
    await PrefUtils().init();
    Get.put(IntroController(autoAdvance: Duration.zero));

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
              name: AppRoutes.shell,
              page: () => const Scaffold(body: Text('shell')),
            ),
            GetPage(
              name: AppRoutes.personalize,
              page: () => const Scaffold(body: Text('personalize')),
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

    expect(Get.currentRoute, AppRoutes.shell);
    expect(find.text('shell'), findsOneWidget);
    // offAll, so the carousel cannot be stepped back onto.
    expect(find.text('Skip'), findsNothing);
    expect(PrefUtils().onboardingSkipped(), isTrue);
  });
}
