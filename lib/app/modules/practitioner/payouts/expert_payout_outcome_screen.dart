import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../widgets/expert_header.dart';

/// The two confirmations the payout flow ends on — Figma "Payout Method
/// Updated" and "Withdrawal Successful".
///
/// One screen, because the frames are the same drawing with different words:
/// a bordered card holding a 100 green disc with a tick, a bold line and a
/// three-line explanation, then Continue pinned at the bottom.
class ExpertPayoutOutcomeScreen extends StatelessWidget {
  const ExpertPayoutOutcomeScreen({super.key});

  /// Passed as `Get.toNamed(..., arguments: PayoutOutcome.methodUpdated)`.
  static PayoutOutcome _of(Object? args) =>
      args is PayoutOutcome ? args : PayoutOutcome.methodUpdated;

  @override
  Widget build(BuildContext context) {
    final outcome = _of(Get.arguments);
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 33.v),
            const ExpertHeader(title: 'Payment Method'),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(24.h, 40.v, 24.h, 40.v),
                      decoration: BoxDecoration(
                        color: appTheme.surface,
                        borderRadius: BorderRadius.circular(8.h),
                        border: Border.all(color: appTheme.radioRim),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 100.h,
                            height: 100.h,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: appTheme.success,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check,
                                size: 56.h, color: appTheme.onPrimary),
                          ),
                          SizedBox(height: 24.v),
                          Text(outcome.title,
                              textAlign: TextAlign.center,
                              style: CustomTextStyles.expertOutcomeTitle),
                          SizedBox(height: 12.v),
                          Text(outcome.body,
                              textAlign: TextAlign.center,
                              style: CustomTextStyles.expertBlurb),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 25.v),
              child: CustomElevatedButton(
                text: 'Continue',
                // Back to Earnings, not back one step: the step behind is the
                // form that was just submitted.
                onPressed: () => Get.until(
                  (route) => route.settings.name == AppRoutes.shell ||
                      route.settings.name == AppRoutes.practitionerDashboard,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Which of the two confirmations is being shown.
enum PayoutOutcome {
  methodUpdated(
    'Payout Method Updated',
    'Your payout details have been saved successfully. You’ll now receive '
        'your earnings based on your selected method.',
  ),
  withdrawalSent(
    'Withdrawal Successful',
    'Your withdrawal request has been submitted successfully. The funds will '
        'be sent to your payout account shortly.',
  );

  const PayoutOutcome(this.title, this.body);

  final String title;
  final String body;
}
