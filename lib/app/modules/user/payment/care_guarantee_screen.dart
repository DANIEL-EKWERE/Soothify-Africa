import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/gradient_text.dart';
import 'controller/booking_payment_controller.dart';

/// "Confirm booking" — Figma `280:26699`, titled *Soothify Care Guarantee
/// Card (Client Checkout Screen)* on the page.
///
/// New in the redrawn section: "Proceed to Payment" on `Therapist booking
/// payment` leads here, and "Pay with Paystack" on to `Success paymet` — so
/// it is the last thing a client sees before paying.
///
/// Measured: the section's chevron + centred "Schedule"; the title at 139 on
/// the brand run; a 14pt Light line at 181; a 342x148 `#E6F7F2` panel at 249,
/// its green heading at 265 and three ticked 10pt promises from 289 at a 32
/// pitch; a 342x104 `#FEFEFE` summary at 429 with a 16 radius, a light
/// hairline round it and between its rows; and the action at 699.
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
    // A single session is the only card the payment screen offers.
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
                onPressed: controller.pay,
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
        borderRadius: BorderRadius.circular(8.h),
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
              Text('The Soothify Care Guarantee',
                  style: CustomTextStyles.careGuaranteeTitle),
            ],
          ),
          SizedBox(height: 8.v),
          for (final promise in CareGuaranteeScreen.promises)
            Padding(
              padding: EdgeInsets.only(left: 36.5.h, top: 8.v),
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    size: 14.h,
                    color: appTheme.textPrimary,
                  ),
                  SizedBox(width: 10.h),
                  Expanded(
                    child: Text(promise,
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
        border: Border.all(color: appTheme.rowBorder.withValues(alpha: 0.5)),
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
          SizedBox(height: 12.v),
          Divider(
            height: 1,
            thickness: 1,
            color: appTheme.rowBorder.withValues(alpha: 0.5),
          ),
          SizedBox(height: 12.v),
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
