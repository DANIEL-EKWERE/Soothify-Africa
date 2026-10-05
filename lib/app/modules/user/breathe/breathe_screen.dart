import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/confetti_overlay.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_ghost_button.dart';
import 'controller/breathe_controller.dart';

/// The 60-second breathing minute — Figma's "Push Notification" section:
/// `313:25770` (invitation), `313:25785` (countdown) and `313:25825`
/// (completion).
///
/// One screen, three phases: the frames share their header and their circle
/// and differ only in what sits under it.
///
/// Measured below the status bar: the title at 75, the circle 210 across
/// centred at 341, the heading at 529, body lines on a 19 pitch from 570, and
/// the actions at 652 and 712.
class BreatheScreen extends GetView<BreatheController> {
  const BreatheScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24.v),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22.h),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: controller.close,
                        customBorder: const CircleBorder(),
                        child: Icon(Icons.close,
                            size: 22.h, color: appTheme.textPrimary),
                      ),
                      Expanded(
                        child: Text(
                          'Breathe in, breathe out',
                          textAlign: TextAlign.center,
                          style: CustomTextStyles.breatheHeader,
                        ),
                      ),
                      SizedBox(width: 22.h),
                    ],
                  ),
                ),
                SizedBox(height: 69.v),
                const Center(child: _BreathCircle()),
                SizedBox(height: 44.v),
                Expanded(
                  child: Obx(
                    () => switch (controller.phase.value) {
                      BreathePhase.invitation => const _Invitation(),
                      BreathePhase.active => const _Active(),
                      BreathePhase.done => const _Done(),
                    },
                  ),
                ),
              ],
            ),
            // The frame rains confetti over the finished screen.
            Obx(
              () => controller.phase.value == BreathePhase.done
                  ? const Positioned.fill(child: ConfettiOverlay())
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

/// The circle, which swells and settles with the cue it is on.
///
/// The frames draw it still, because a frame cannot do otherwise. A minute
/// spent watching a circle that does not move is a minute with nothing to
/// breathe along with, so it breathes.
class _BreathCircle extends StatefulWidget {
  const _BreathCircle();

  @override
  State<_BreathCircle> createState() => _BreathCircleState();
}

class _BreathCircleState extends State<_BreathCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _swell = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _swell.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BreatheController>();
    final still = MediaQuery.disableAnimationsOf(context);

    return Obx(() {
      final active = controller.phase.value == BreathePhase.active;
      if (!still && active && !_swell.isAnimating) {
        _swell.repeat(reverse: true);
      } else if ((!active || still) && _swell.isAnimating) {
        _swell.stop();
      }
      return AnimatedBuilder(
        animation: _swell,
        builder: (context, _) {
          // 1.0 at rest, up to 1.06 at the top of a breath.
          final scale = active
              ? 1 + 0.06 * math.sin(_swell.value * math.pi)
              : 1.0;
          return Transform.scale(
            scale: scale,
            child: Container(
              height: 210.h,
              width: 210.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: appTheme.breatheCircleGradient,
                boxShadow: [
                  BoxShadow(
                    color: appTheme.soothifyBlue.withValues(alpha: 0.18),
                    blurRadius: 36,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

class _Invitation extends StatelessWidget {
  const _Invitation();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BreatheController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 39.v),
          Text(
            'Find your center today',
            textAlign: TextAlign.center,
            style: CustomTextStyles.breatheHeading,
          ),
          SizedBox(height: 22.v),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 26.h),
            child: Text(
              'Take 60 seconds to step away from the noise, regulate your '
              'breathing, and protect your peace.',
              textAlign: TextAlign.center,
              style: CustomTextStyles.breatheBody,
            ),
          ),
          const Spacer(),
          CustomElevatedButton(
            text: 'Start Meditation',
            onPressed: controller.start,
          ),
          SizedBox(height: 8.v),
          CustomGhostButton(
            text: 'Not right now',
            color: appTheme.soothifyBlue,
            onPressed: controller.decline,
          ),
          SizedBox(height: 28.v),
        ],
      ),
    );
  }
}

class _Active extends StatelessWidget {
  const _Active();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BreatheController>();
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(horizontal: 48.h),
        child: Column(
          children: [
            SizedBox(height: 146.v),
            Text(controller.clock, style: CustomTextStyles.breatheHeading),
            SizedBox(height: 17.v),
            Text(
              controller.cue.label,
              textAlign: TextAlign.center,
              style: CustomTextStyles.breatheBody,
            ),
          ],
        ),
      ),
    );
  }
}

class _Done extends StatelessWidget {
  const _Done();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BreatheController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 34.v),
          Text(
            'You did it',
            textAlign: TextAlign.center,
            style: CustomTextStyles.breatheHeading,
          ),
          SizedBox(height: 25.v),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 26.h),
            child: Text(
              'You just completed your daily meditation. Your streak is '
              'officially active for today.',
              textAlign: TextAlign.center,
              style: CustomTextStyles.breatheBody,
            ),
          ),
          SizedBox(height: 29.v),
          // The frame sets a 🔥 in the string. Neither bundled face carries
          // an emoji glyph, so it drew as a blank box — the flame is an icon.
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_fire_department,
                    size: 20.h, color: appTheme.accent),
                SizedBox(width: 6.h),
                Text(
                  'Day ${controller.streak.value} Streak',
                  style: CustomTextStyles.breatheStreak,
                ),
              ],
            ),
          ),
          const Spacer(),
          CustomElevatedButton(
            text: 'Return to Home',
            onPressed: controller.returnHome,
          ),
          SizedBox(height: 8.v),
          CustomGhostButton(
            text: 'Explore Today’s Classes',
            color: appTheme.soothifyBlue,
            onPressed: controller.exploreClasses,
          ),
          SizedBox(height: 28.v),
        ],
      ),
    );
  }
}
