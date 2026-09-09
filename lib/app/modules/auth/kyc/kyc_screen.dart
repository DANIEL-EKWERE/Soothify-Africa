import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/kyc_question.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/gradient_text.dart';
import '../../../widgets/step_progress_bar.dart';
import 'controller/kyc_controller.dart';
import 'widgets/age_wheel.dart';
import 'widgets/kyc_concern_carousel.dart';
import 'widgets/kyc_option_tile.dart';

/// The KYC questionnaire — Figma section "Mobile / KYC".
///
/// Six questions share one screen because the frames differ only in prompt,
/// options and input type: 2214:25489 (concerns), 25531 (frequency), 25559
/// (treatment), 25583 (goals), 25635 (gender) and 25651 (age).
///
/// Positions from the design: progress at 84, prompt at 140, the optional
/// "select more than one" line at 174, and the first row at 228 — or 253 when
/// that line is present.
///
/// The design's progress component carries five segments (the fifth clipped
/// off-frame) while there are six questions, so the bar here is driven by the
/// question count instead.
class KycScreen extends GetView<KycController> {
  const KycScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // The concerns step is a screen of its own shape — full-bleed colour,
      // no side padding, its own progress accent — so it replaces the body
      // rather than living inside the shared column.
      if (controller.question.input == KycInput.carousel) {
        return Scaffold(
          body: KycConcernCarousel(question: controller.question),
        );
      }
      return _standard();
    });
  }

  Widget _standard() {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.h),
          child: Obx(() {
            final question = controller.question;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 37.h),
                StepProgressBar(
                  totalSteps: controller.totalSteps,
                  currentStep: controller.step.value + 1,
                ),
                SizedBox(height: 52.4.h),
                GradientText(
                  question.prompt,
                  gradient: appTheme.titleGradient,
                  style: CustomTextStyles.onboardingTitle,
                ),
                if (question.subtitle != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    question.subtitle!,
                    style: CustomTextStyles.onboardingSubtitle,
                  ),
                ],
                SizedBox(height: 30.h),
                Expanded(child: _Answers(question: question)),
                Obx(
                  () => CustomElevatedButton(
                    text: 'Next',
                    isLoading: controller.isLoading.value,
                    isEnabled: controller.canProceed,
                    onPressed: controller.next,
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _Answers extends StatelessWidget {
  const _Answers({required this.question});

  final KycQuestion question;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KycController>();

    if (question.input == KycInput.wheel) {
      return Obx(
        () => AgeWheel(
          // Keyed by question so switching steps rebuilds the wheel rather
          // than reusing the previous question's scroll position.
          key: ValueKey(question.id),
          options: question.options,
          selectedValue:
              controller.current.isEmpty ? null : controller.current.first,
          onSelected: controller.choose,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          for (final option in question.options) ...[
            // Obx per row: the enclosing build does not re-run when only the
            // selection changes.
            Obx(
              () => KycOptionTile(
                option: option,
                isSelected: controller.isChosen(option),
                onTap: () => controller.choose(option),
              ),
            ),
            if (option != question.options.last) SizedBox(height: 21.h),
          ],
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
