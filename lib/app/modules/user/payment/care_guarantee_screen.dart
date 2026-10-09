import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import 'controller/booking_payment_controller.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/gradient_text.dart';
import '../../../widgets/soothify_word.dart';

/// "Confirm booking" — Figma `280:26699`, titled *Soothify Care Guarantee
/// Card (Client Checkout Screen)* on the page.
///
/// New in the redrawn section: it sits between `Therapist booking payment`
/// and `Success paymet`, so it is the last thing a client sees before paying.
///
/// Measured: the section's chevron + centred "Schedule"; the title at 139 on
/// the brand run; a 14pt Light line at 181; a 342x148 `#E6F7F2` panel at 249
/// under a 1px `#263238` hairline, its green heading at 265 and three 10pt
/// promises from 289 at a 32 pitch; a 342x104 `#FEFEFE` summary at 429 with a
/// 16 radius; and the action at 699.
class CareGuaranteeScreen extends GetView<BookingPaymentController> {
  const CareGuaranteeScreen({super.key});

  /// What the panel promises, in the frame's order.
  static const List<String> promises = [
    'Hassle-free session rescheduling & instant support',
    'Earn Soothify Wellness Points for discounts on future sessions',
    'Encrypted clinical session notes saved securely for your progress',
  ];

  @override
  Widget build(BuildContext context) {
    // Through the controller, not the raw arguments: the calendar sends a
    // BookedSlot now, and reading for a bare offering quietly priced every
    // session as therapy. `money` is also the one place the figure is
    // grouped and given its currency.
    final price = BookingPaymentController.money(controller.offering.single);

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
                    child: Text('Schedule',
                        textAlign: TextAlign.center,
                        style: CustomTextStyles.appBarTitle),
                  ),
                  SizedBox(width: 24.h),
                ],
              ),
              SizedBox(height: 51.v),
              GradientText(
                'Confirm booking',
                gradient: appTheme.authHeaderGradient,
                style: CustomTextStyles.kycQuestion,
              ),
              SizedBox(height: 16.v),
              Text(
                'Secure your spot to unlock your calendar link and start your '
                'journey',
                style: CustomTextStyles.policyScreenBody,
              ),
              SizedBox(height: 32.v),
              const _GuaranteePanel(),
              SizedBox(height: 32.v),
              _Summary(price: price),
              const Spacer(),
              CustomElevatedButton(
                text: 'Pay with Paystack',
                // Carrying whatever brought us here, so the confirmation at
                // the end of the chain can still name the day and time.
                onPressed: () => Get.toNamed(
                  AppRoutes.paymentSuccess,
                  arguments: Get.arguments,
                ),
              ),
              SizedBox(height: 93.v),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuaranteePanel extends StatelessWidget {
  const _GuaranteePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.h, 16.v, 16.h, 16.v),
      decoration: BoxDecoration(
        color: appTheme.careGuarantee,
        // No outline: the frame draws the panel as a tint alone. It was
        // ringed in near black, which is the same misreading the joining
        // screen's green panel had.
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomImageView(
                imagePath: ImageConstant.icWarning,
                height: 20.h,
                width: 20.h,
              ),
              SizedBox(width: 16.h),
              SoothifyText('The Soothify Care Guarantee',
                  style: CustomTextStyles.careGuaranteeTitle),
            ],
          ),
          SizedBox(height: 8.v),
          // Each promise is ticked in the frame, not bulleted or bare.
          for (final promise in CareGuaranteeScreen.promises)
            Padding(
              padding: EdgeInsets.only(left: 6.h, top: 10.v),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 2.v),
                    child: Icon(Icons.check,
                        size: 16.h, color: appTheme.successInk),
                  ),
                  SizedBox(width: 10.h),
                  Expanded(
                    child: SoothifyText(promise,
                        style: CustomTextStyles.careGuaranteeItem),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.price});

  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104.v,
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: appTheme.textPrimary),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Session', style: CustomTextStyles.summaryLabel),
              Text(price, style: CustomTextStyles.summaryValue),
            ],
          ),
          SizedBox(height: 24.6.v),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: CustomTextStyles.summaryValue),
              Text(price, style: CustomTextStyles.summaryValue),
            ],
          ),
        ],
      ),
    );
  }
}
