import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/core/app_export.dart';
import 'app/core/utils/initial_bindings.dart';
import 'app/data/services/language_service.dart';
import 'app/data/services/session_service.dart';
import 'app/data/services/theme_service.dart';
import 'app/routes/app_pages.dart';

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
        return GetMaterialApp(
          title: 'Soothify Africa',
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splash,
          theme: theme,
          darkTheme: darkTheme,
          themeMode: Get.find<ThemeService>().mode.value,
          initialBinding: InitialBindings(),
          getPages: AppPages.pages,
          builder: (context, child) {
            // Point the global palette at whichever ThemeData resolved here.
            // This runs on every theme change, manual or system, so
            // `appTheme` never lags what is painted.
            PrimaryColors.syncFrom(context);

            // Pin text scaling so the Figma layouts stay predictable.
            // Revisit once accessibility sizing is designed for.
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },
        );
      },
    );
  }
}
