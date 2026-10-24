import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/core/app_export.dart';
import 'app/core/utils/initial_bindings.dart';
import 'app/core/network/api_client.dart';
import 'app/core/network/app_api_client.dart';
import 'app/data/repositories/api_device_token_repository.dart';
import 'app/data/repositories/device_token_repository.dart';
import 'app/data/services/language_service.dart';
import 'app/data/services/push_service.dart';
import 'app/data/services/session_service.dart';
import 'app/data/services/theme_service.dart';
import 'app/routes/app_pages.dart';
import 'app/widgets/ai_assist_overlay.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Services that need async setup are resolved before the first frame so no
  // screen has to defend against a half-initialised dependency.
  await PrefUtils().init();
  await Get.putAsync(() => SessionService().init(), permanent: true);
  await Get.putAsync(() => ThemeService().init(), permanent: true);
  await Get.putAsync(() => LanguageService().init(), permanent: true);
  await Get.putAsync(() => NetworkInfo().init(), permanent: true);

  // Push. Firebase first, then the background handler — it has to be
  // registered before a message can arrive, and it runs in its own isolate,
  // so it is a top-level function rather than a method.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(soothifyBackgroundMessage);
  Get.put(buildApiClient(), permanent: true);
  // The Django endpoint. It holds the token locally until there is a session
  // to register it against — see ApiDeviceTokenRepository.
  Get.put<DeviceTokenRepository>(
    ApiDeviceTokenRepository(Get.find<ApiClient>()),
    permanent: true,
  );
  await Get.putAsync(
    () => PushService(Get.find<DeviceTokenRepository>()).init(),
    permanent: true,
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Edge to edge, so the transparent status bar reveals the screen behind it
  // rather than a system-painted band.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const SoothifyApp());

  // Permission and the token are network calls that can hang for tens of
  // seconds on a captive or slow connection. They must never be awaited
  // before runApp, or the app sits on a blank screen waiting for them.
  unawaited(Get.find<PushService>().start());
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
            // One transition for the whole app. Pushes slide in from the
            // right and fade at the same time — directional enough to say
            // "deeper in", soft enough for a wellness app. Individual routes
            // override it in AppPages where they read as sheets rather than
            // pages.
            defaultTransition: Transition.rightToLeftWithFade,
            transitionDuration: const Duration(milliseconds: 280),

            // Tells the app-wide assist button which screen is on
            // top, so it can stay out of onboarding and auth.
            routingCallback: AiAssistOverlay.onRouting,
            builder: (context, child) {
              // Resolve the palette from the *service*, not from
              // `Theme.of(context)`.
              //
              // MaterialApp animates between themes, and `ThemeData.lerp`
              // switches `brightness` only at the half-way point — so for the
              // first half of a toggle `Theme.of` still reports the OLD
              // brightness. `syncFrom` therefore re-pinned the old palette on
              // the very rebuild the toggle triggered, and nothing rebuilt
              // again once the animation crossed over. That is why a theme
              // change only appeared after killing the app.
              final dark = Get.find<ThemeService>().isDark(context);
              PrimaryColors.active = PrimaryColors.of(
                dark ? Brightness.dark : Brightness.light,
              );

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
