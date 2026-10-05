import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
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
                padding: EdgeInsets.fromLTRB(24.h, 55.5.v, 24.h, 0),
                children: [
                  GradientText(
                    'Ready for your session with ${controller.expertName}',
                    gradient: appTheme.titleGradient,
                    style: CustomTextStyles.paymentHeadline,
                  ),
                  SizedBox(height: 17.5.v),
                  Text(
                    'Secure your spot to unlock your calendar link and start '
                    'your journey',
                    style: CustomTextStyles.paymentSubtitle,
                  ),
                  // What is being paid for, now that the day is chosen before
                  // the price rather than after it.
                  if (controller.booked != null) ...[
                    SizedBox(height: 14.v),
                    Row(
                      children: [
                        Icon(Icons.event_outlined,
                            size: 16.h, color: appTheme.soothifyBlue),
                        SizedBox(width: 8.h),
                        Expanded(
                          child: Text(
                            controller.booked!.summary,
                            style: CustomTextStyles.paymentWhen,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 28.5.v),
                  // One card now, and it lists what the session includes.
                  // The redrawn screen dropped the Monthly Plan card beside
                  // it; `SessionPlan.monthly` and the prices behind it are
                  // left in the model, so bringing it back is a matter of
                  // drawing it again.
                  _SessionCard(
                    title: 'Single Session',
                    amount: offering.single,
                    unit: '/50-minute session',
                  ),
                  if (offering.hasCancellationPolicy) ...[
                    SizedBox(height: 32.v),
                    const _CancellationPolicy(),
                  ],
                  // 32 between the panel and the action, as the frame draws
                  // it. Without this the button sat flush against the policy.
                  SizedBox(height: 32.v),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 46.v),
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
/// What the session gets you, as the designer's screenshot lists it.
abstract final class SessionCardIncludes {
  static const List<String> lines = [
    'Full 1-on-1 personalized attention',
    'Direct calendar booking link instantly unlocked',
    'Flexible rescheduling up to 24 hours prior',
  ];
}

/// The filled card the redrawn screen leads with — the price and what the
/// session includes, on the brand's deep blue.
class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.title,
    required this.amount,
    required this.unit,
  });

  final String title;
  final int amount;
  final String unit;

  static List<String> get includes => SessionCardIncludes.lines;

  @override
  Widget build(BuildContext context) {
    final white = appTheme.onPrimary;
    return Container(
      padding: EdgeInsets.fromLTRB(24.h, 24.v, 24.h, 23.v),
      decoration: BoxDecoration(
        color: appTheme.planEmphasisFill,
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: CustomTextStyles.planOptionTitle.copyWith(color: white),
          ),
          SizedBox(height: 12.v),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: BookingPaymentController.money(amount),
                  style: CustomTextStyles.planOptionPrice
                      .copyWith(color: white),
                ),
                TextSpan(
                  text: unit,
                  style: CustomTextStyles.planOptionUnit.copyWith(color: white),
                ),
              ],
            ),
          ),
          SizedBox(height: 22.v),
          for (final line in includes) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2.v),
                  child: Icon(Icons.check, size: 12.h, color: white),
                ),
                // 44.5 of indent off the card's edge, as the screenshot sets
                // it: 24 of padding, a 12 tick and 8.5 after it.
                SizedBox(width: 8.5.h),
                Expanded(
                  child: Text(
                    line,
                    style: CustomTextStyles.sessionInclude.copyWith(
                      color: white,
                    ),
                  ),
                ),
              ],
            ),
            if (line != includes.last) SizedBox(height: 8.v),
          ],
        ],
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
      padding: EdgeInsets.fromLTRB(17.h, 13.5.v, 24.h, 17.v),
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
          SizedBox(height: 5.v),
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
                SizedBox(height: 15.5.v),
                Text(
                  'Cancellation made less than 24 hours before the session '
                  'are not eligible for a refund.',
                  style: CustomTextStyles.policyBody,
                ),
                SizedBox(height: 11.v),
                GestureDetector(
                  onTap: controller.openPolicy,
                  child: Text('Payment & Policy',
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
