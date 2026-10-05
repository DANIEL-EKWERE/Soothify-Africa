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

  /// How long each prompt stays up, measured from the moment it is swapped
  /// in. [fade] eats the first 2.2s of that, so the word stands fully lit for
  /// 1.6 — paced for an actual breath rather than a UI transition, because
  /// this is the one moment the app asks you to slow down.
  static const breathHold = Duration(milliseconds: 3800);

  /// How long the outgoing word takes to reach nothing at all, and the same
  /// again for the incoming one.
  static const fadeOutMs = 600;

  /// The empty beat between the two words — a second of nothing, so one has
  /// plainly gone before the next arrives.
  static const gapMs = 1000;

  /// One swap, start to finish: out, the gap, then in.
  static const fadeMs = fadeOutMs + gapMs + fadeOutMs;
  static const fade = Duration(milliseconds: fadeMs);

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
// noted another issue, the kyc screens, the grid card never get selected for the "next" button to get activated.

// secondly the mood icon when clicked, eas supposed to toggle the theming of the app, but it doesn't.

// thirdly the the ai therapy assist, doesn't get drawn to the edge of the screen when dragged and left at the middle of the screen.

// cd "/home/daniel/Desktop/flutter apps/SoothifyAfrica/soothifyafrica" && flutter test -r compact 2>&1 | tail -c 200

// what's the meaning of that command?