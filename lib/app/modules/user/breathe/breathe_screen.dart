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

/// The circle, which breathes the cycle rather than decorating it.
///
/// The frames draw it still, because a frame cannot do otherwise. It is the
/// thing the user breathes along with, so it has to move with the cue and not
/// merely near it: it swells over the four seconds of the inhale, holds its
/// size for the two of the hold, and settles back over the six of the exhale.
///
/// One repeating 12-second pass drives it — the whole cycle, not a sine wave
/// that happens to be about the right length — so the size and the line under
/// the clock always agree.
class _BreathCircle extends StatefulWidget {
  const _BreathCircle();

  /// The circle at its smallest, as a fraction of the frame's 210.
  static const double _restScale = 0.66;

  @override
  State<_BreathCircle> createState() => _BreathCircleState();
}

class _BreathCircleState extends State<_BreathCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _swell = AnimationController(
    vsync: this,
    duration: Duration(seconds: BreatheCue.cycleSeconds),
  );

  @override
  void dispose() {
    _swell.dispose();
    super.dispose();
  }

  /// How full the lungs are, 0 at rest and 1 at the top of a breath.
  ///
  /// Eased at both ends of the inhale and the exhale, so the turn is a pause
  /// rather than a bounce — the circle should never look like it snapped.
  double _fullness() {
    final (cue, through) = BreatheCue.at(_swell.value * BreatheCue.cycleSeconds);
    return switch (cue) {
      BreatheCue.inhale => Curves.easeInOutSine.transform(through),
      BreatheCue.hold => 1,
      BreatheCue.exhale => 1 - Curves.easeInOutSine.transform(through),
    };
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BreatheController>();
    final still = MediaQuery.disableAnimationsOf(context);

    return Obx(() {
      final active = controller.phase.value == BreathePhase.active;
      if (!still && active && !_swell.isAnimating) {
        // From 0 — the start of an inhale — so the first thing the user sees
        // is the circle opening under "Breathe in".
        _swell.repeat();
      } else if ((!active || still) && _swell.isAnimating) {
        _swell.stop();
      }
      return AnimatedBuilder(
        animation: _swell,
        builder: (context, child) {
          // Outside the minute — and wherever motion is turned off — the
          // circle sits at the size the frames draw it.
          final scale = active && !still
              ? _BreathCircle._restScale +
                  (1 - _BreathCircle._restScale) * _fullness()
              : 1.0;
          return Transform.scale(scale: scale, child: child);
        },
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
