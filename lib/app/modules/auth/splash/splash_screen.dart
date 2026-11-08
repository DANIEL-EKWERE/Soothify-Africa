import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_export.dart';
import '../../../data/repositories/kyc_repository.dart';
import '../../../data/services/ambience_service.dart';
import '../../../data/services/push_service.dart';
import '../../../data/services/session_service.dart';
import 'splash_timing.dart';
import 'start_route.dart';

/// Splash — the wordmark, then a breath, then the app.
///
/// Deliberately a StatefulWidget rather than a GetView. The screen never reads
/// a controller, so a GetX controller behind it was never constructed and the
/// redirect never ran — the app sat here. initState always runs, so the
/// handoff cannot be skipped.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  // The durations live in splash_timing.dart and are re-exported here, so
  // this is still where you look for them. They moved out because the
  // stream that fades up under the prompts has to be timed against them,
  // and a service importing this screen — which imports the service — is a
  // cycle.
  static const brandHold = SplashTiming.brandHold;
  static const fadeOutMs = SplashTiming.fadeOutMs;
  static const gapMs = SplashTiming.gapMs;
  static const fadeMs = SplashTiming.fadeMs;
  static const fade = SplashTiming.fade;
  static const litMs = SplashTiming.litMs;
  static const breathHold = SplashTiming.breathHold;
  static const prompts = SplashTiming.prompts;

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

    // The stream comes up as the wordmark leaves, over one word-swap, so it
    // is at full in the same moment "Inhale Deeply" finishes arriving. Not
    // awaited: opening a codec can take a moment on a cold start and the
    // prompts must not wait on it.
    if (Get.isRegistered<AmbienceService>()) {
      unawaited(Get.find<AmbienceService>().start());
    }

    for (var i = 0; i < SplashScreen.prompts.length; i++) {
      // Guarded at every step: the widget can be disposed if something else
      // navigates first, and this sequence runs for several seconds.
      if (!mounted) return;
      setState(() => _step = i);
      await Future<void>.delayed(SplashScreen.breathHold);
    }

    if (!mounted) return;
    Get.offAllNamed(route);

    // Three more seconds wherever that landed -- the shell, the intro
    // carousel on a first launch, the questionnaire, a studio's portal --
    // and then it fades away. Told here rather than from the destination,
    // because every destination would otherwise have to remember to.
    if (Get.isRegistered<AmbienceService>()) {
      Get.find<AmbienceService>().land();
    }

    // A notification the user tapped to launch the app is held until there
    // is something to push onto — which is now, after the splash has handed
    // over. Pushing it before this point lands on a stack `offAllNamed` is
    // about to throw away.
    if (Get.isRegistered<PushService>()) Get.find<PushService>().openPending();
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

  /// Where in [SplashScreen.fade] a word is wholly gone, and wholly absent:
  /// the fade out ends here counting down, and the fade in starts here
  /// counting up.
  static const double _fadeStop =
      1 - SplashScreen.fadeOutMs / SplashScreen.fadeMs;

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
            // Sequential, not overlapping.
            //
            // AnimatedSwitcher's default runs both children linearly across
            // the whole duration, so half way through "Inhale Deeply" and
            // "Exhale Slowly" are each at 50% in the same spot — they ghost
            // through one another and the line visibly dims.
            //
            // Both curves are read against the controller's *value*, and the
            // outgoing child's controller runs backwards from 1 to 0. So the
            // outgoing word is gone once the value drops below `_fadeStop` —
            // which is `fadeOut` into the swap — and the incoming one does
            // not begin until its own value climbs past the same mark, which
            // is `fadeOut + gap` in. Mirroring the intervals instead, as this
            // did, left no empty beat at all: both met in the middle.
            switchOutCurve: const Interval(_fadeStop, 1, curve: Curves.easeIn),
            switchInCurve: const Interval(_fadeStop, 1, curve: Curves.easeOut),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                // Barely perceptible, and deliberately so: it is the words
                // that should feel like breathing, not the layout moving.
                scale: Tween<double>(begin: 0.97, end: 1).animate(animation),
                child: child,
              ),
            ),
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
