import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/passport_tier.dart';
import '../../../widgets/custom_elevated_button.dart';

/// The end of the Passport purchase.
///
/// The frame set draws no success screen for this flow, so this is the
/// payment receipt the booking chain already ends on — the same green disc
/// and the same Continue — with the tier named, because a pass that was
/// just bought should say which one.
class PassportSuccessScreen extends StatelessWidget {
  const PassportSuccessScreen({super.key});

  static PassportTier? _of(Object? args) =>
      args is PassportTier ? args : null;

  @override
  Widget build(BuildContext context) {
    final tier = _of(Get.arguments);
    return PopScope(
      // Nothing to go back to: the tier list behind this would offer to
      // charge again.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _done();
      },
      child: Scaffold(
        backgroundColor: appTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 141.v),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.h),
                child: Container(
                  padding: EdgeInsets.fromLTRB(24.h, 48.v, 24.h, 48.v),
                  decoration: BoxDecoration(
                    color: appTheme.surface,
                    borderRadius: BorderRadius.circular(8.h),
                    border: Border.all(color: appTheme.rowBorder),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 95.h,
                        height: 95.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: appTheme.success,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 56.h,
                          color: appTheme.onPrimary,
                        ),
                      ),
                      SizedBox(height: 34.v),
                      Text(
                        'Your payment was successful',
                        textAlign: TextAlign.center,
                        style: CustomTextStyles.paymentSuccess,
                      ),
                      if (tier != null) ...[
                        SizedBox(height: 12.v),
                        Text(
                          '${tier.name} is active. ${tier.allowance} this '
                          'month.',
                          textAlign: TextAlign.center,
                          style: CustomTextStyles.passportFor,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 25.v),
                child: CustomElevatedButton(
                  text: 'Continue',
                  onPressed: _done,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Back to the app, not back to the tiers: that screen is spent.
  void _done() => Get.offAllNamed(AppRoutes.shell);
}
