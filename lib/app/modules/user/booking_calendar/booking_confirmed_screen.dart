import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';

/// "Your session is booked" — the end of the booking chain.
///
/// Mirrors the receipt (`259:36140`) so the two reads of "it worked" look
/// alike; the line beneath names the day that was picked.
class BookingConfirmedScreen extends StatelessWidget {
  const BookingConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final when = Get.arguments is String ? Get.arguments as String : '';
    return PopScope(
      // Nothing behind this is worth returning to — the calendar it replaced
      // would offer to book the same session again.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _home();
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
                  height: 364.v,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 24.h),
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
                        'Your session is booked',
                        textAlign: TextAlign.center,
                        style: CustomTextStyles.paymentSuccess,
                      ),
                      if (when.isNotEmpty) ...[
                        SizedBox(height: 12.v),
                        Text(
                          when,
                          textAlign: TextAlign.center,
                          style: CustomTextStyles.coachBlurb,
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
                  text: 'Done',
                  onPressed: _home,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _home() =>
      Get.until((route) => Get.currentRoute == AppRoutes.shell);
}
