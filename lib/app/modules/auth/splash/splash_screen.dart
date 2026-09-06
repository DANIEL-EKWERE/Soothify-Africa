import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_export.dart';
import '../../../data/repositories/kyc_repository.dart';
import '../../../data/services/session_service.dart';
import 'start_route.dart';

/// Splash — the wordmark, then a breath, then the app.
///
/// Deliberately a StatefulWidget rather than a GetView. The screen never reads
/// a controller, so a GetX controller behind it was never constructed and the
/// redirect never ran — the app sat here. initState always runs, so the
/// handoff cannot be skipped.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// How long the wordmark holds before the breathing prompts begin.
  static const brandHold = Duration(seconds: 3);

  /// How long each prompt stays up. Paced for an actual breath rather than a
  /// UI transition — this is the one moment the app asks you to slow down.
  static const breathHold = Duration(milliseconds: 2600);

  static const fade = Duration(milliseconds: 700);

  /// The prompts, in order.
  static const prompts = ['Inhale Deeply', 'Exhale Slowly'];

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// -1 is the wordmark; 0..prompts.length-1 are the breathing prompts.
  int _step = -1;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    // Resolved up front so the wait is the brand moment, not a lookup.
    final route = await resolveStartRoute(
      session: Get.find<SessionService>(),
      kyc: Get.find<KycRepository>(),
    );

    await Future<void>.delayed(SplashScreen.brandHold);
    for (var i = 0; i < SplashScreen.prompts.length; i++) {
      // Guarded at every step: the widget can be disposed if something else
      // navigates first, and this sequence runs for several seconds.
      if (!mounted) return;
      setState(() => _step = i);
      await Future<void>.delayed(SplashScreen.breathHold);
    }

    if (!mounted) return;
    Get.offAllNamed(route);
  }

  @override
  Widget build(BuildContext context) => SplashView(step: _step);
}

/// The splash's appearance, with no timers attached.
///
/// Split out so it can be rendered — in a golden, or anywhere else — without
/// starting the sequence or needing the session and KYC dependencies.
class SplashView extends StatelessWidget {
  const SplashView({super.key, this.step = -1});

  /// -1 shows the wordmark; 0 and up show the matching breathing prompt.
  final int step;

  @override
  Widget build(BuildContext context) {
    final showingBrand = step < 0;
    // Transparent bar with light icons rather than a hidden one: hiding it
    // makes the system paint a black band where it was, which is exactly the
    // chrome the full-bleed splash is trying to avoid. Left transparent, the
    // brand gradient runs to the top of the screen instead, and the icons go
    // light because this is the app's one dark background.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: AppDecoration.brandGradient,
          alignment: Alignment.center,
          // One crossfade for the whole sequence: the wordmark fades out as
          // the first prompt fades in, and each prompt replaces the last.
          child: AnimatedSwitcher(
            duration: SplashScreen.fade,
            child: showingBrand
                ? SvgPicture.asset(
                    ImageConstant.svgWordmark,
                    key: const ValueKey('wordmark'),
                    width: 194.h,
                    semanticsLabel: 'Soothify',
                  )
                : Text(
                    SplashScreen.prompts[step],
                    key: ValueKey(step),
                    textAlign: TextAlign.center,
                    style: CustomTextStyles.breathPrompt,
                  ),
          ),
        ),
      ),
    );
  }
}
