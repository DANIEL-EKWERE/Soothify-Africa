import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/policy_section.dart';
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

  /// The policy in full, supplied by the designer on 2026-10-03.
  ///
  /// The frame (`280:26738`) carries two summary sentences — "You cancel your
  /// session for a full refund if you cancel at least 24 hours before your
  /// scheduled session." and its negative. This screen's own purpose is to
  /// spell the policy out where the payment panel summarises, so the two
  /// sentences gave way to the document; section 2 is that same 24-hour rule,
  /// stated in full.
  static const String effectiveDate = 'Effective Date: October 2, 2026';

  static const List<PolicySection> sections = [
    PolicySection('1. Subscription Cancellation', [
      'You may cancel your Soothify subscription at any time through your '
          'account settings or app store management portal. Cancellation '
          'takes effect at the end of the current active billing period. You '
          'will retain uninterrupted access to the Platform until your paid '
          'or trial period officially expires. No partial refunds are issued '
          'for unused portions of an active billing cycle.',
    ]),
    PolicySection(
      '2. Live Session / Booking Cancellation Window (Strict 24-Hour Rule)',
      [
        'For any live-instructor sessions, specialized bookings, or '
            'interactive add-ons offered via the Platform:',
        'Cancellations made more than 24 hours prior to the scheduled session '
            'start time are eligible for a reschedule or a refund, subject to '
            'applicable processing fees.',
        'Cancellations made less than 24 hours before the scheduled session '
            'start time are strictly non-refundable. Because instructor time, '
            'crew schedules, and production resources are locked in advance, '
            'late cancellations forfeit all rights to a refund or credit.',
      ],
    ),
    PolicySection('3. Refund Processing & Administrative Fees', [
      'In the event an approved refund is processed outside of standard '
          'statutory cooling-off periods, Soothify reserves the right to '
          'deduct a mandatory administrative and gateway processing fee to '
          'cover third-party merchant transaction costs. Approved refunds are '
          'credited back exclusively to the original payment method within '
          'standard banking processing timelines.',
    ]),
  ];

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
              // The frame heads this "Cancellation Policy"; the document
              // behind it also covers refunds, and is titled accordingly.
              //
              // Not [authHeaderGradient]: its stops finish the colour change
              // by 53%, which on this longer heading left "Cancellation" blue
              // and "& Refund Policy" flat navy. Same two colours, run across
              // the whole string.
              GradientText(
                'Cancellation & Refund Policy',
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF2F6FED), Color(0xFF274889)],
                ),
                style: CustomTextStyles.kycQuestion,
              ),
              SizedBox(height: 12.v),
              Text(effectiveDate, style: CustomTextStyles.policyEffectiveDate),
              SizedBox(height: 16.v),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(bottom: 16.v),
                  children: [
                    for (final section in sections) ...[
                      Text(
                        section.heading,
                        style: CustomTextStyles.policyScreenHeading,
                      ),
                      SizedBox(height: 8.v),
                      for (final paragraph in section.paragraphs) ...[
                        Text(
                          paragraph,
                          style: CustomTextStyles.policyScreenBody,
                        ),
                        SizedBox(height: 12.v),
                      ],
                      SizedBox(height: 12.v),
                    ],
                  ],
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
