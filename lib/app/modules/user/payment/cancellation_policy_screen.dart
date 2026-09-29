import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/gradient_text.dart';

/// The cancellation policy in full — Figma `280:26738`, new in the redrawn
/// "Book a licensed Expert" section.
///
/// It sits directly under `Therapist booking payment` (280:26535) on the
/// page, which is where it is reached from: the payment screen's policy panel
/// summarises, this spells it out.
///
/// Measured: the section's usual header — a 24-square chevron at (24, 64)
/// with "Schedule" centred beside it — then the title at 139 on the
/// `#2F6FED -> #274889` run, the body at 181 across 342, and the action
/// pinned at 725 (343x52, 67 clear of the bottom).
class CancellationPolicyScreen extends StatelessWidget {
  const CancellationPolicyScreen({super.key});

  /// The frame's wording, verbatim but for a double space in "at least  24
  /// hours".
  ///
  /// I first shipped this believing the frame's string was cut off at "...for
  /// a full refund if you" and substituted the payment panel's copy. That was
  /// my own `tool/figma.py spec` clipping every string at 48 characters, not
  /// the design. The two turned out to be the same sentence anyway; the
  /// printer no longer truncates.
  static const String body =
      'You cancel your session for a full refund if you cancel at least 24 '
      'hours before your scheduled session.\n\n'
      'Cancellation made less than 24 hours before the session are not '
      'eligible for a refund.';

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
              SizedBox(height: 17.v),
              Row(
                children: [
                  InkWell(
                    onTap: Get.back,
                    child: CustomImageView(
                      imagePath: ImageConstant.icBack,
                      height: 24.h,
                      width: 24.h,
                      color: appTheme.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Schedule',
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.appBarTitle,
                    ),
                  ),
                  SizedBox(width: 24.h),
                ],
              ),
              SizedBox(height: 51.v),
              GradientText(
                'Cancellation Policy',
                gradient: appTheme.authHeaderGradient,
                style: CustomTextStyles.kycQuestion,
              ),
              SizedBox(height: 16.v),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(body, style: CustomTextStyles.policyScreenBody),
                ),
              ),
              // The frame's label reads "Go Bavk".
              CustomElevatedButton(
                text: 'Go Back',
                onPressed: Get.back,
              ),
              SizedBox(height: 67.v),
            ],
          ),
        ),
      ),
    );
  }
}
