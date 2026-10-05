import 'package:flutter/material.dart';

import '../core/app_export.dart';
import '../data/models/environment_vibe.dart';
import '../modules/user/ai_hub/controller/ai_hub_controller.dart';
import '../modules/user/ai_hub/widgets/breathing_scene.dart';

/// The assistant as a floating panel — Figma "Maximize screen" (`259:58711`).
///
/// The frame draws the breathing scene detached into a 194x182 window over
/// whatever is behind it, with the expand controls at its top right, the
/// hint pill across the middle, and a transport row beneath.
///
/// Measured off the frame's own render rather than its JSON: both node
/// budgets were spent when this was built, so the panel's size and the
/// controls' bands are measured and the spacing within them is proportional.
/// Worth re-measuring against `259:58711` when a budget returns.
class AiMiniPlayer extends StatelessWidget {
  const AiMiniPlayer({
    super.key,
    required this.onExpand,
    required this.onClose,
  });

  /// Opens the full hub. Both the expand glyph and the scene itself do this —
  /// the frame's own hint says "Tap Droplet or Chat to Expand".
  final VoidCallback onExpand;

  /// Puts the assistant back to its button.
  final VoidCallback onClose;

  static const double width = 194;
  static const double height = 182;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AiHubController>();
    return Material(
      color: appTheme.transparent,
      child: Container(
        width: width.h,
        height: height.v,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.h),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: onExpand,
                child: Obx(
                  () => BreathingSceneLoop(
                    playing: controller.playing.value,
                    palette: ScenePalette.of(controller.vibe.value),
                    period: AiHubController.breathPeriod,
                    onCycle: controller.countBreath,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 6.v,
              right: 10.h,
              child: Row(
                children: [
                  _Glyph(icon: Icons.close_fullscreen, onTap: onClose),
                  SizedBox(width: 10.h),
                  _Glyph(icon: Icons.open_in_full, onTap: onExpand),
                ],
              ),
            ),
            Positioned(
              top: 29.v,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  height: 20.v,
                  padding: EdgeInsets.symmetric(horizontal: 11.h),
                  decoration: BoxDecoration(
                    color: appTheme.pillDark.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(10.h),
                  ),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      'Tap Droplet or Chat to Expand',
                      style: CustomTextStyles.aiPanelHint,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 72.v,
              left: 0,
              right: 0,
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // The frame gives no job to these two. The only thing the
                    // hub has a sequence of is its environment vibes, and
                    // stepping through them is what the scene can actually
                    // do, so that is what they do.
                    _Transport(
                      icon: Icons.skip_previous,
                      size: 28,
                      onTap: () => _step(controller, -1),
                    ),
                    SizedBox(width: 26.h),
                    _Transport(
                      icon: controller.playing.value
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 40,
                      onTap: controller.togglePlaying,
                    ),
                    SizedBox(width: 26.h),
                    _Transport(
                      icon: Icons.skip_next,
                      size: 28,
                      onTap: () => _step(controller, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _step(AiHubController controller, int by) {
    const vibes = EnvironmentVibe.values;
    final next = (controller.vibe.value.index + by) % vibes.length;
    controller.selectVibe(vibes[next < 0 ? next + vibes.length : next]);
  }
}

/// One of the two expand controls at the panel's top right.
class _Glyph extends StatelessWidget {
  const _Glyph({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: EdgeInsets.all(4.h),
        child: Icon(icon, size: 15.h, color: appTheme.onPrimary),
      ),
    );
  }
}

/// A transport button: a translucent disc with a white glyph.
class _Transport extends StatelessWidget {
  const _Transport({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        height: size.h,
        width: size.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: appTheme.onPrimary.withValues(alpha: 0.22),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: (size * 0.5).h, color: appTheme.onPrimary),
      ),
    );
  }
}
