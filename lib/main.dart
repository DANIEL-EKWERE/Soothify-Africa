import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/core/app_export.dart';
import 'app/core/utils/initial_bindings.dart';
import 'app/data/services/language_service.dart';
import 'app/data/services/session_service.dart';
import 'app/data/services/theme_service.dart';
import 'app/routes/app_pages.dart';
import 'app/widgets/ai_assist_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Services that need async setup are resolved before the first frame so no
  // screen has to defend against a half-initialised dependency.
  await PrefUtils().init();
  await Get.putAsync(() => SessionService().init(), permanent: true);
  await Get.putAsync(() => ThemeService().init(), permanent: true);
  await Get.putAsync(() => LanguageService().init(), permanent: true);
  await Get.putAsync(() => NetworkInfo().init(), permanent: true);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Edge to edge, so the transparent status bar reveals the screen behind it
  // rather than a system-painted band.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const SoothifyApp());
}

class SoothifyApp extends StatelessWidget {
  const SoothifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, constraints, orientation) {
        // Navigator 1.0. GetMaterialApp.router puts GetX in Navigator 2.0
        // mode, where Get.toNamed/offAllNamed do not drive the route delegate
        // — every navigation silently did nothing and the app sat on the
        // splash. Driving a router build needs Get.rootDelegate.* at every
        // call site; named routes here still give deep links and browser URLs.
        // Obx so a theme change actually repaints. `themeMode` was read
        // outside any observer, so toggling updated the service and nothing
        // rebuilt — Get.changeThemeMode cannot win against an explicit
        // themeMode that never changes.
        return Obx(
          () => GetMaterialApp(
            title: 'Soothify Africa',
            debugShowCheckedModeBanner: false,
            initialRoute: AppRoutes.splash,
            theme: theme,
            darkTheme: darkTheme,
            themeMode: Get.find<ThemeService>().mode.value,
            initialBinding: InitialBindings(),
            getPages: AppPages.pages,
            // Tells the app-wide assist button which screen is on
            // top, so it can stay out of onboarding and auth.
            routingCallback: AiAssistOverlay.onRouting,
            builder: (context, child) {
              // Point the global palette at whichever ThemeData resolved here.
              // This runs on every theme change, manual or system, so
              // `appTheme` never lags what is painted.
              PrimaryColors.syncFrom(context);

              // Transparent status bar with dark icons, so the app's own
              // background runs to the top of the screen. The icon brightness
              // follows the theme rather than being pinned dark: black glyphs
              // on the dark palette's near-black background would vanish.
              final dark = Theme.of(context).brightness == Brightness.dark;

              // Pin text scaling so the Figma layouts stay predictable.
              // Revisit once accessibility sizing is designed for.
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  // Android reads the icon brightness; iOS reads the bar's.
                  statusBarIconBrightness: dark
                      ? Brightness.light
                      : Brightness.dark,
                  statusBarBrightness: dark
                      ? Brightness.dark
                      : Brightness.light,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarIconBrightness: dark
                      ? Brightness.light
                      : Brightness.dark,
                ),
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(1.0)),
                  // Over the navigator, so one instance of the assist button
                  // outlives every route change.
                  child: AiAssistOverlay(child: child!),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
