import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_ghost_button.dart';
import '../../../widgets/gradient_text.dart';
import 'controller/expert_application_controller.dart';

/// "Join the Soothify Expert Network" — Figma
/// `Join expert application onboarding screen` (`259:59132`).
///
/// Measured: the title 115 (292 wide, two lines at a 32.7 pitch, centred),
/// the body 197 (346 wide, two lines at 21.8), a 346-square image at 265,
/// "Start Application" at 659 and "Back" at 727, both 52 tall.
class ExpertIntroScreen extends GetView<ExpertApplicationController> {
  const ExpertIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(22.h, 71.v, 22.h, 24.v),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 27.h),
                child: GradientText(
                  'Join the Soothify Expert Network',
                  // Steeper than the app's titleGradient: this frame runs
                  // #2F6FED to #274889.
                  gradient: LinearGradient(
                    colors: [appTheme.soothifyBlue, appTheme.expertIntroInk],
                  ),
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.expertIntroTitle,
                ),
              ),
              SizedBox(height: 16.v),
              Text(
                'Bring your practice to a global audience. Help clients heal '
                'and grow in English or Pidgin.',
                textAlign: TextAlign.center,
                style: CustomTextStyles.expertIntroBody,
              ),
              SizedBox(height: 24.v),
              // The frame's own artwork was not exported; the Explore tile
              // for "Book a Licensed Expert" is the same subject and already
              // ships.
              ClipRRect(
                borderRadius: BorderRadius.circular(8.h),
                child: CustomImageView(
                  imagePath: ImageConstant.imgExpertNetwork,
                  height: 346.h,
                  width: 346.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 48.v),
              // Somebody who has already applied is told where it stands
              // rather than invited to apply again -- a second application
              // is one more thing for a reviewer to read and no faster an
              // answer for them.
              Obx(() {
                final sent = controller.existing.value;
                if (sent != null && sent.isPending) {
                  return Column(
                    children: [
                      Text(
                        'Your application is with us — ${sent.statusLabel}.',
                        textAlign: TextAlign.center,
                        style: CustomTextStyles.expertIntroBody,
                      ),
                      SizedBox(height: 8.v),
                      Text(
                        'We read every one ourselves, usually within 24 to '
                        '48 hours, and write to you either way.',
                        textAlign: TextAlign.center,
                        style: CustomTextStyles.expertIntroBody,
                      ),
                    ],
                  );
                }
                return CustomElevatedButton(
                  text: sent != null && sent.isRejected
                      ? 'Apply again'
                      : 'Start Application',
                  onPressed: controller.start,
                );
              }),
              SizedBox(height: 16.v),
              CustomGhostButton(
                text: 'Back',
                color: appTheme.soothifyBlue,
                onPressed: Get.back,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
