import 'package:flutter/material.dart';

import '../core/app_export.dart';
import 'ai_assist_button.dart';

/// Holds the AI Therapy Assist button above the whole app.
///
/// It used to live inside the Home tab, which meant it vanished the moment you
/// opened anything — a chat head that only exists on one screen is not a chat
/// head. Mounted here, over the navigator, one instance survives every push
/// and pop, so where the user parked it is where it stays.
class AiAssistOverlay extends StatelessWidget {
  const AiAssistOverlay({super.key, required this.child});

  final Widget child;

  /// Onboarding, auth and the splash. The button is an in-app affordance and
  /// has no business floating over a sign-up form or the brand animation.
  static const _hidden = {
    AppRoutes.splash,
    AppRoutes.intro,
    AppRoutes.personalize,
    AppRoutes.language,
    AppRoutes.signup,
    AppRoutes.signin,
    AppRoutes.roleSelect,
    AppRoutes.kyc,
  };

  /// The route on top, kept as an observable so the overlay can react to a
  /// push it did not make. Fed by [GetMaterialApp.routingCallback].
  static final RxnString route = RxnString();

  static void onRouting(Routing? routing) => route.value = routing?.current;

  /// The shell's bottom navigation. Parking the button over it would cover a
  /// tab, so the draggable area stops short of it.
  static const _navHeight = 74.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Obx(() {
            final at = route.value ?? AppRoutes.splash;
            if (_hidden.contains(at)) return const SizedBox.shrink();
            return SafeArea(
              minimum: EdgeInsets.only(
                bottom: at == AppRoutes.shell ? _navHeight.v : 0,
              ),
              // LayoutBuilder so the button knows the area it may be dragged
              // within; without it a drag could put it off-screen.
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  children: [
                    AiAssistButton(
                      onTap: openAiAssist,
                      bounds: constraints.biggest,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// What the button does. Its own screen is not in the design yet.
void openAiAssist() => AppFeedback.info('AI Therapy Assist is not built yet.');
