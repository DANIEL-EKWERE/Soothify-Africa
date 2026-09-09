import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/environment_vibe.dart';
import '../../../widgets/custom_elevated_button.dart';
import 'controller/ai_hub_controller.dart';
import 'widgets/breathing_scene.dart';
import 'widgets/guide_chat.dart';

/// AI Therapy Assist — Figma "AI Hub | Unexpanded" (page 124:2, `176:56425`)
/// and "AI Hub | Expanded | Chat" (`176:56395`).
///
/// One screen with two states. Collapsed it is a scene panel over its
/// readouts, a vibe picker and "Breathe Together"; expanded, the same scene
/// fills the screen and carries the Wellness Guide conversation. The frames'
/// own copy — "Tap Droplet or Chat to Expand" — is what says these are one
/// screen rather than two.
///
/// Measurements below the status bar, from the frame: panel 52..285 (233
/// tall), readouts 314, rule 371, section label 400, segments 421 (40 tall),
/// button 485 (52 tall).
class AiHubScreen extends GetView<AiHubController> {
  const AiHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: Obx(
        () => controller.expanded.value
            ? const GuideChat()
            : const _Collapsed(),
      ),
    );
  }
}

class _Collapsed extends StatelessWidget {
  const _Collapsed();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AiHubController>();
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 52.v),
            const _ScenePanel(),
            SizedBox(height: 29.v),
            const _Readouts(),
            SizedBox(height: 26.v),
            Container(height: 1.v, color: appTheme.aiDivider),
            SizedBox(height: 28.v),
            Text(
              'Select Environment Vibe',
              style: CustomTextStyles.aiSectionLabel,
            ),
            SizedBox(height: 11.v),
            const _VibePicker(),
            SizedBox(height: 24.v),
            CustomElevatedButton(
              text: 'Breathe Together',
              onPressed: controller.breatheTogether,
            ),
            SizedBox(height: 32.v),
          ],
        ),
      ),
    );
  }
}

/// The scene, its pause control and the tap hint.
class _ScenePanel extends StatelessWidget {
  const _ScenePanel();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AiHubController>();
    return GestureDetector(
      onTap: controller.expand,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.h),
        child: SizedBox(
          height: 233.v,
          child: Stack(
            children: [
              Positioned.fill(
                child: Obx(() => BreathingSceneLoop(
                      playing: controller.playing.value,
                    )),
              ),
              Positioned(
                top: 50.v,
                left: 0,
                right: 0,
                child: Center(
                  // No `alignment` on the pill's own box: with one set it
                  // would stretch to the panel instead of hugging its label.
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
                top: 12.v,
                right: 9.h,
                child: Obx(() => _PauseButton(
                      playing: controller.playing.value,
                      onTap: controller.togglePlaying,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  const _PauseButton({required this.playing, required this.onTap});

  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        height: 28.h,
        width: 28.h,
        decoration: BoxDecoration(
          color: appTheme.onPrimary.withValues(alpha: 0.22),
          shape: BoxShape.circle,
        ),
        child: Icon(
          playing ? Icons.pause : Icons.play_arrow,
          size: 16.h,
          color: appTheme.onPrimary,
        ),
      ),
    );
  }
}

/// Vibe, Breathing Pace and Ease Level — three centred columns, spread across
/// the content width.
class _Readouts extends StatelessWidget {
  const _Readouts();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AiHubController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => _Readout(
              label: 'Vibe',
              value: controller.vibe.value.label,
            )),
        _Readout(label: 'Breathing Pace', value: controller.breathingPace),
        _Readout(label: 'Ease Level', value: controller.easeLevel),
      ],
    );
  }
}

class _Readout extends StatelessWidget {
  const _Readout({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: CustomTextStyles.aiStatLabel),
        SizedBox(height: 8.v),
        Text(value, style: CustomTextStyles.aiStatValue),
      ],
    );
  }
}

class _VibePicker extends StatelessWidget {
  const _VibePicker();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AiHubController>();
    return Container(
      height: 40.v,
      decoration: BoxDecoration(
        color: appTheme.segmentTrack,
        borderRadius: BorderRadius.circular(20.h),
        border: Border.all(color: appTheme.segmentTrackBorder),
      ),
      child: Row(
        children: [
          for (final v in EnvironmentVibe.values)
            Expanded(
              child: Obx(() {
                final selected = controller.vibe.value == v;
                return InkWell(
                  onTap: () => controller.selectVibe(v),
                  borderRadius: BorderRadius.circular(20.h),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? appTheme.actionFill
                          : appTheme.transparent,
                      borderRadius: BorderRadius.circular(20.h),
                    ),
                    child: Text(
                      v.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: selected
                          ? CustomTextStyles.aiSegmentSelected
                          : CustomTextStyles.aiSegmentLabel,
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}
