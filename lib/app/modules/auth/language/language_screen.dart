import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/gradient_text.dart';
import 'controller/language_controller.dart';
import 'widgets/language_row.dart';

/// "Choose Your Preferred Language to Continue" — Figma 655:5390 (untouched)
/// and 655:5402 (English selected).
///
/// Positions inside the 390x844 frame: title at 219, rows at 320 and 382
/// (342x48, 14 apart), Next at 573.
class LanguageScreen extends GetView<LanguageController> {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Proportional spacers, not fixed heights. The design places
              // the title at 219, rows at 320 and Next at 573 within an
              // 844-tall frame; pinning those gaps overflowed by 376px on a
              // shorter screen. These flex values reproduce the design's
              // spacing at reference size and compress below it.
              const Spacer(flex: 172),
              GradientText(
                'Choose Your Preferred Language to Continue',
                gradient: appTheme.titleGradient,
                textAlign: TextAlign.center,
                style: CustomTextStyles.onboardingSlideTitle,
              ),
              SizedBox(height: 49.h),
              for (final language in controller.languages) ...[
                // Obx per row, not around the list: the enclosing build does
                // not re-run when only the selection changes.
                Obx(
                  () => LanguageRow(
                    language: language,
                    isSelected: controller.selected.value == language,
                    onTap: () => controller.select(language),
                  ),
                ),
                if (language != controller.languages.last)
                  SizedBox(height: 14.h),
              ],
              const Spacer(flex: 143),
              Obx(
                () => Opacity(
                  // The design dims Next to 50% rather than recolouring it,
                  // which is how this screen differs from the KYC one.
                  opacity: controller.canProceed ? 1 : 0.5,
                  // isEnabled stays true so the fill remains the design's
                  // #2233B5; the Opacity above supplies the disabled look.
                  child: CustomElevatedButton(
                    text: 'Next',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.canProceed ? controller.next : null,
                  ),
                ),
              ),
              const Spacer(flex: 219),
            ],
          ),
        ),
      ),
    );
  }
}
