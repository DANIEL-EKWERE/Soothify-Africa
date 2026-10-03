import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import 'controller/corporate_controller.dart';

/// "Corporate form successful" — Figma `259:36093`.
///
/// Measured below the status bar: card 24..367 wide and 185..550 down, radius
/// 16 inside a #999999 hairline at 50%; the tick 92 across, centred, its top
/// at 285; the line centred at 409 across 277; Continue at 695, 52 tall.
class CorporateSuccessScreen extends GetView<CorporateController> {
  const CorporateSuccessScreen({super.key});

  static const String message =
      'Thank you for your interest! Our team will contact you shortly to '
      'discuss your custom wellness program';

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
              SizedBox(height: 185.v),
              Container(
                height: 365.v,
                decoration: BoxDecoration(
                  color: appTheme.surface,
                  borderRadius: BorderRadius.circular(16.h),
                  border: Border.all(
                    color: appTheme.filterRule.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 100.v),
                    Container(
                      height: 92.h,
                      width: 92.h,
                      // The frame fills #34C759 and rings it in #4CAF50;
                      // the two greens are a shade apart, so the ring would
                      // not be visible and [success] carries both.
                      decoration: BoxDecoration(
                        color: appTheme.success,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 52.h,
                        color: appTheme.onPrimary,
                      ),
                    ),
                    SizedBox(height: 31.v),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 33.h),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: CustomTextStyles.corporateLabel,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              CustomElevatedButton(
                text: 'Continue',
                onPressed: controller.done,
              ),
              SizedBox(height: 45.v),
            ],
          ),
        ),
      ),
    );
  }
}
