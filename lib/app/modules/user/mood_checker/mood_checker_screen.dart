import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import 'controller/mood_checker_controller.dart';

/// Mood Checker — Figma page 124:2, light `176:22410`-`176:22479`, dark
/// `176:31360`-`176:31429`.
///
/// One character illustration over a slider running "Awful" to "Awesome", and
/// an "Add Detail" button. Dragging the handle changes the face: the artwork
/// is the scale, which is why only the two ends carry words.
///
/// This replaced a 3x3 grid of emoji tiles from the older file.
class MoodCheckerScreen extends GetView<MoodCheckerController> {
  const MoodCheckerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            ImageConstant.icChevronLeft,
            height: 24.h,
            width: 24.h,
            // The exported SVG is black; tint it so it stays visible on the
            // dark palette.
            colorFilter:
                ColorFilter.mode(appTheme.textPrimary, BlendMode.srcIn),
          ),
          onPressed: () =>
              Get.key.currentState?.canPop() == true ? Get.back() : null,
        ),
        title: const Text('Mood Checker'),
      ),
      body: SafeArea(
        // Scrolls only as a guard: the stack below adds up to the design's
        // 741 points under the app bar, so on the reference frame nothing
        // moves. A short screen scrolls rather than overflowing.
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Spacing measured off the frame, in points below the app bar:
              // heading 44, figure 154, slider track centre 464, labels 489,
              // button 570.
              SizedBox(height: 44.v),
              Text(
                'How do you feel today?',
                textAlign: TextAlign.center,
                style: CustomTextStyles.screenQuestion,
              ),
              SizedBox(height: 91.v),
              SizedBox(
                height: 203.v,
                child: Center(child: Obx(() => _Figure(
                      path: controller.artPath,
                    ))),
              ),
              SizedBox(height: 83.v),
              const _Slider(),
              SizedBox(height: 74.v),
              Obx(() => CustomElevatedButton(
                    text: 'Add Detail',
                    isLoading: controller.isSaving.value,
                    onPressed: controller.submit,
                  )),
              SizedBox(height: 118.v),
            ],
          ),
        ),
      ),
    );
  }
}

/// The character. Cross-fades between steps so dragging the handle reads as
/// one face changing rather than four images cutting.
class _Figure extends StatelessWidget {
  const _Figure({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Image.asset(
        path,
        // Keyed by path, or AnimatedSwitcher treats every step as the same
        // child and never crossfades.
        key: ValueKey(path),
        fit: BoxFit.contain,
      ),
    );
  }
}

class _Slider extends StatelessWidget {
  const _Slider();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MoodCheckerController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 12.v,
            activeTrackColor: appTheme.moodTrackActive,
            inactiveTrackColor: appTheme.moodTrackInactive,
            thumbColor: appTheme.moodThumb,
            overlayColor: appTheme.moodThumb.withValues(alpha: 0.12),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 11.h),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 22.h),
            trackShape: const RoundedRectSliderTrackShape(),
            // The frame shows no value bubble; the face is the readout.
            showValueIndicator: ShowValueIndicator.never,
          ),
          child: Obx(() => Slider(
                value: controller.score.value,
                onChanged: controller.setScore,
                // Announced rather than drawn: a screen reader cannot see the
                // illustration that carries the meaning.
                semanticFormatterCallback: (_) => controller.level.label,
              )),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Awful', style: CustomTextStyles.moodScaleEnd),
            Text('Awesome', style: CustomTextStyles.moodScaleEnd),
          ],
        ),
      ],
    );
  }
}
