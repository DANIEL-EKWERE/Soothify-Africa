import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import 'controller/booking_payment_controller.dart';

/// The receipt — Figma "Success paymet" (`259:36140`, `259:58911`).
///
/// Measured: a card at 185, 343 wide and 364 tall, with a 95 green disc
/// centred at y=350, its one line at 431.5, and the action at 693.
///
/// The frame writes "Your was Payment successful" — the words are in the
/// wrong order. Corrected here; a receipt is the last place to ship a
/// scrambled sentence.
class PaymentSuccessScreen extends GetView<BookingPaymentController> {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // There is nothing to go back to: the payment screen behind this is
      // spent, and stepping onto it would offer to charge again.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.done();
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
                      Text('Your payment was successful',
                          style: CustomTextStyles.paymentSuccess),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 25.v),
                child: CustomElevatedButton(
                  text: 'Continue',
                  onPressed: controller.done,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
