import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_ghost_button.dart';
import '../../../widgets/gradient_text.dart';
import 'controller/personalize_controller.dart';

/// Figma 655:5377 — "Mobile / Language Screen", first panel.
///
/// Positions inside the 390x844 frame: artwork 216x241 at (88, 169), title at
/// 467, body at 540, Continue at 627 and Skip at 701, both 343x52.
class PersonalizeScreen extends GetView<PersonalizeController> {
  const PersonalizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.h),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Image.asset(
                'assets/images/onboarding/personalize.png',
                width: 216.h,
                height: 241.h,
                fit: BoxFit.contain,
              ),
              const Spacer(flex: 3),
              GradientText(
                "Welcome! Let's Personalize Soothify for You!",
                gradient: appTheme.titleGradient,
                textAlign: TextAlign.center,
                style: CustomTextStyles.onboardingSlideTitle,
              ),
              SizedBox(height: 21.h),
              Text(
                'Help us understand your preferences to provide the best '
                'experience.',
                textAlign: TextAlign.center,
                style: CustomTextStyles.onboardingBody,
              ),
              const Spacer(flex: 2),
              CustomElevatedButton(
                text: 'Continue',
                onPressed: controller.onContinue,
              ),
              SizedBox(height: 22.h),
              CustomGhostButton(
                text: 'Skip',
                color: appTheme.textPrimary,
                backgroundColor: appTheme.transparent,
                textStyle: CustomTextStyles.secondaryButtonLabel,
                onPressed: controller.onSkip,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
