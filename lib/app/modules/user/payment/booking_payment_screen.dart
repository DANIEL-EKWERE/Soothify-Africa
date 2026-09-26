import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/session_offering.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/gradient_text.dart';
import 'controller/booking_payment_controller.dart';

/// Choosing a plan and paying for a session — Figma `259:58862` (therapist),
/// `259:58919` and `259:58941` (the two tracks, identical to each other).
///
/// Measured below the status bar: the header 69, the headline 144.5 over two
/// lines at a 26 pitch, the subtitle 211 at a 21 pitch, the Single Session
/// card 275 (103 tall) and Monthly Plan 395 (104), both 342 wide with a 12
/// radius and 32 of inset. The therapist frame then puts the cancellation
/// policy at 531 (162 tall) and its button at 725; the track frames put the
/// button at 693 and one centred line beneath it.
class BookingPaymentScreen extends GetView<BookingPaymentController> {
  const BookingPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final offering = controller.offering;
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 22.v),
            const _Header(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 61.5.v, 24.h, 24.v),
                children: [
                  GradientText(
                    'Ready for your session with ${controller.expertName}',
                    gradient: appTheme.titleGradient,
                    style: CustomTextStyles.paymentHeadline,
                  ),
                  SizedBox(height: 22.v),
                  Text(
                    'Secure your spot to unlock your calendar link and start '
                    'your journey',
                    style: CustomTextStyles.paymentSubtitle,
                  ),
                  SizedBox(height: 33.v),
                  Obx(
                    // Both cards are the full 342 the frame draws; without
                    // this each sizes to its own label and they disagree.
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PlanCard(
                          plan: SessionPlan.single,
                          title: 'Single Session',
                          amount: offering.single,
                          unit: '/50-minute session',
                          selected: controller.plan.value == SessionPlan.single,
                        ),
                        SizedBox(height: 17.v),
                        _PlanCard(
                          plan: SessionPlan.monthly,
                          title: 'Monthly Plan',
                          amount: offering.monthly,
                          unit: '/monthly',
                          selected:
                              controller.plan.value == SessionPlan.monthly,
                        ),
                      ],
                    ),
                  ),
                  if (offering.hasCancellationPolicy) ...[
                    SizedBox(height: 32.v),
                    const _CancellationPolicy(),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 27.v),
              child: Column(
                children: [
                  CustomElevatedButton(
                    text: 'Proceed to Payment',
                    onPressed: controller.proceed,
                  ),
                  // The therapist frame carries the full policy panel instead
                  // of this line; the two track frames carry the line.
                  if (!offering.hasCancellationPolicy) ...[
                    SizedBox(height: 27.v),
                    Text(
                      'Free cancellation or rescheduling up to 24 hours '
                      'before your session',
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.paymentFootnote,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Row(
        children: [
          InkWell(
            onTap: Get.back,
            child: CustomImageView(
              imagePath: ImageConstant.icBack,
              height: 18.h,
              width: 18.h,
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
          SizedBox(width: 18.h),
        ],
      ),
    );
  }
}

/// One of the two prices.
///
/// The chosen card is filled deep navy with white type; the other is white
/// inside a blue hairline. That is how the frames draw Monthly and Single
/// respectively, and it is the only selected state they give.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.title,
    required this.amount,
    required this.unit,
    required this.selected,
  });

  final SessionPlan plan;
  final String title;
  final int amount;
  final String unit;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingPaymentController>();
    final onFill = selected ? appTheme.onPrimary : null;

    return GestureDetector(
      onTap: () => controller.select(plan),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 103.v,
        padding: EdgeInsets.symmetric(horizontal: 32.h),
        decoration: BoxDecoration(
          color: selected ? appTheme.planEmphasisFill : appTheme.surface,
          borderRadius: BorderRadius.circular(12.h),
          border: selected
              ? null
              : Border.all(color: appTheme.soothifyBlue),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: CustomTextStyles.planOptionTitle
                  .copyWith(color: onFill),
            ),
            SizedBox(height: 16.v),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: BookingPaymentController.money(amount),
                    style: CustomTextStyles.planOptionPrice
                        .copyWith(color: onFill),
                  ),
                  TextSpan(
                    text: unit,
                    style: CustomTextStyles.planOptionUnit.copyWith(
                      color: selected
                          ? appTheme.onPrimary.withValues(alpha: 0.75)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The pale panel the therapist frame carries in place of the footnote.
class _CancellationPolicy extends StatelessWidget {
  const _CancellationPolicy();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingPaymentController>();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(17.h, 17.v, 24.h, 18.v),
      decoration: BoxDecoration(
        color: appTheme.policyPanel,
        borderRadius: BorderRadius.circular(8.h),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 18.h,
                color: appTheme.soothifyBlue,
              ),
              SizedBox(width: 17.h),
              Text('Cancellation Policy',
                  style: CustomTextStyles.policyTitle),
            ],
          ),
          SizedBox(height: 7.5.v),
          Padding(
            padding: EdgeInsets.only(left: 35.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You cancel your session for a full refund if you cancel '
                  'at least 24 hours before your scheduled session.',
                  style: CustomTextStyles.policyBody,
                ),
                SizedBox(height: 21.5.v),
                Text(
                  'Cancellation made less than 24 hours before the session '
                  'are not eligible for a refund.',
                  style: CustomTextStyles.policyBody,
                ),
                SizedBox(height: 12.5.v),
                GestureDetector(
                  onTap: controller.openPolicy,
                  child: Text('Payment & policy',
                      style: CustomTextStyles.policyLink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
