import 'package:flutter/material.dart';

import '../core/app_export.dart';
import '../modules/user/ai_hub/controller/ai_hub_controller.dart';
import '../modules/user/shell/widgets/app_bottom_nav.dart';
import 'ai_assist_button.dart';
import 'ai_mini_player.dart';

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
    // The hub is the button's own destination; it has no business
    // floating over it.
    AppRoutes.aiHub,
  };

  /// The route on top, kept as an observable so the overlay can react to a
  /// push it did not make. Fed by [GetMaterialApp.routingCallback].
  static final RxnString route = RxnString();

  /// Whether the assistant is showing as its floating panel rather than its
  /// button — Figma "Maximize screen" (`259:58711`).
  ///
  /// The button used to open the hub outright. The frame puts this panel
  /// between the two: the scene floats where the button was, and expanding
  /// from there is what opens the hub.
  static final RxBool expanded = false.obs;

  static void onRouting(Routing? routing) => route.value = routing?.current;

  /// The shell's bottom navigation. Parking the button over it would cover a
  /// tab, so the draggable area stops short of it — of the whole bar,
  /// including the system inset the bar now sits above.

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
                bottom: at == AppRoutes.shell
                    ? AppBottomNav.heightFor(context)
                    : 0,
              ),
              // LayoutBuilder so the button knows the area it may be dragged
              // within; without it a drag could put it off-screen.
              child: LayoutBuilder(
                builder: (context, constraints) => Obx(
                  () => Stack(
                    children: [
                      if (expanded.value)
                        Positioned(
                          top: 16.v,
                          right: 16.h,
                          child: AiMiniPlayer(
                            onExpand: openAiAssist,
                            onClose: () => expanded.value = false,
                          ),
                        )
                      else
                        AiAssistButton(
                          // Straight to the hub. The panel in between was
                          // read off `259:58711`, but it puts a second thing
                          // to dismiss in front of the one the button is
                          // for.
                          onTap: openAiAssist,
                          bounds: constraints.biggest,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Floats the scene where the button was standing.
///
/// **Nothing calls this.** The button goes straight to the hub now; the panel
/// `259:58711` draws is kept, with this, so bringing it back is one line.
///
/// The controller has to exist before the panel can draw the scene; nothing
/// else puts it up until the hub route is opened.
void openMiniPlayer() {
  if (Get.currentRoute == AppRoutes.aiHub) return;
  if (!Get.isRegistered<AiHubController>()) {
    Get.put(AiHubController(), permanent: true);
  }
  AiAssistOverlay.expanded.value = true;
}

/// Expanding the panel — the AI Hub, Figma `176:56425` / `176:56395`.
void openAiAssist() {
  // Tapping it again while the hub is open would stack a second copy.
  if (Get.currentRoute == AppRoutes.aiHub) return;
  // The panel is what the hub expands from, so it stands down behind it.
  AiAssistOverlay.expanded.value = false;
  Get.toNamed(AppRoutes.aiHub);
}
