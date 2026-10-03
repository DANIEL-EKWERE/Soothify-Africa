import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/gradient_text.dart';
import 'controller/language_controller.dart';
import 'widgets/language_row.dart';

/// "How would you like to converse?" — Figma `259:25752`, which replaced
/// "Choose Your Preferred Language to Continue".
///
/// The frame holds both sentences in **one** text node: the question at the
/// base weight (Nunito Sans Bold 20) and "Choose your preferred language."
/// at weight 300, both on the `#2F6FED -> #274889` run. They fall on separate
/// lines at 310 wide, so they are drawn here as two stacked blocks rather
/// than one rich span.
///
/// Positions inside the 390x844 frame: title at 219, rows at 320 and 382
/// (342x48 at an 8 radius, 14 apart), Next at 573.
///
/// The file draws this twice — `259:25752` in the onboarding run and
/// `259:37703` among the Settings frames. Opened from Settings it gains a
/// back arrow and its button reads "Save Language"; the rest is this layout,
/// because the Settings frame could not be read (both Figma budgets were
/// spent when it was built) and is worth re-measuring when they return.
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
              // Settings pushed this route on top of itself, so there is a
              // stack to go back to; onboarding arrives by `offAllNamed` and
              // has none.
              if (controller.fromSettings)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 20.v),
                    child: InkWell(
                      onTap: Get.back,
                      child: CustomImageView(
                        imagePath: ImageConstant.icBack,
                        height: 18.h,
                        width: 18.h,
                        color: appTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              // Proportional spacers, not fixed heights. The design places
              // the title at 219, rows at 320 and Next at 573 within an
              // 844-tall frame; pinning those gaps overflowed by 376px on a
              // shorter screen. These flex values reproduce the design's
              // spacing at reference size and compress below it.
              const Spacer(flex: 172),
              GradientText(
                'How would you like to converse?',
                gradient: appTheme.titleGradient,
                textAlign: TextAlign.center,
                style: CustomTextStyles.onboardingSlideTitle,
              ),
              GradientText(
                'Choose your preferred language.',
                gradient: appTheme.titleGradient,
                textAlign: TextAlign.center,
                style: CustomTextStyles.onboardingSlideSubtitle,
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
                    text: controller.entry.action,
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
