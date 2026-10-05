import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/membership.dart';
import '../../../widgets/custom_ghost_button.dart';
import 'controller/trial_offer_controller.dart';

/// "Soothify payment" — Figma `311:25477` (credit card chosen, 390x1312) and
/// `311:25582` (Apple Pay chosen, 390x977).
///
/// One screen: the two frames differ only in which method is selected and
/// whether the card form is expanded beneath it.
///
/// Measured below the status bar: the wordmark at 57, the title at 108, the
/// blurb at 145, "Plan summary" at 205 with its card at 238 (342x318), the
/// method heading at 576, the options at 607 and 677 (342x58 each), the card
/// form filling 393 when open, the promo row, the authorisation note, and the
/// action at the foot.
///
/// **The card frame prints dollars** — "$245.00", "save $115 a year" — where
/// the Apple Pay frame prints naira for the same amounts. Naira is used
/// throughout here: it matches the rest of the app, the pop-up in front of
/// this screen, and the Apple Pay variant of this one.
class TrialPaymentScreen extends GetView<TrialOfferController> {
  const TrialPaymentScreen({super.key});

  static const String authorisation =
      'By continuing, you agree to Soothify’s Terms & Conditions, Privacy '
      'Policy, and Refund Policy. Cancel anytime in your account settings.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10.v),
            Center(
              child: Text('Soothify', style: CustomTextStyles.paymentWordmark),
            ),
            SizedBox(height: 16.v),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 24.v),
                children: [
                  Text(
                    'Try Soothify free for 7 days',
                    textAlign: TextAlign.center,
                    style: CustomTextStyles.paymentTitle,
                  ),
                  SizedBox(height: 11.v),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.h),
                    child: Text(
                      'Choose your payment method to start your free trial. '
                      'Cancel anytime',
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.paymentBlurb,
                    ),
                  ),
                  SizedBox(height: 24.v),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Plan summary',
                          style: CustomTextStyles.paymentSection),
                      InkWell(
                        onTap: Get.back,
                        child: Text('Change',
                            style: CustomTextStyles.paymentLink),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.v),
                  Obx(() => _PlanSummary(plan: controller.plan.value)),
                  SizedBox(height: 20.v),
                  Text('Payment method',
                      style: CustomTextStyles.paymentSection),
                  SizedBox(height: 11.v),
                  Obx(() => _Methods(chosen: controller.method.value)),
                  SizedBox(height: 25.v),
                  Text('Have a promo code?',
                      style: CustomTextStyles.paymentFieldLabel),
                  SizedBox(height: 8.v),
                  const _PromoRow(),
                  SizedBox(height: 20.v),
                  Text(authorisation, style: CustomTextStyles.paymentFinePrint),
                  SizedBox(height: 24.v),
                  CustomGhostButton(
                    text: 'Start My Free Week',
                    color: appTheme.soothifyBlue,
                    onPressed: controller.startFreeWeek,
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

/// What is being bought, and what is actually taken today.
class _PlanSummary extends StatelessWidget {
  const _PlanSummary({required this.plan});

  final MembershipPlan plan;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrialOfferController>();
    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: appTheme.cardHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                plan == MembershipPlan.annual ? 'Annual' : 'Monthly',
                style: CustomTextStyles.paymentPlanName,
              ),
              if (plan.hasSaving) ...[
                SizedBox(width: 8.h),
                Container(
                  height: 20.v,
                  padding: EdgeInsets.symmetric(horizontal: 8.h),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: appTheme.paymentWash,
                    borderRadius: BorderRadius.circular(20.h),
                  ),
                  child: Text('save ₦15,000 a year',
                      style: CustomTextStyles.paymentChip),
                ),
              ],
            ],
          ),
          SizedBox(height: 4.v),
          Text(
            plan == MembershipPlan.annual ? 'Billed annually' : 'Billed monthly',
            style: CustomTextStyles.paymentMuted,
          ),
          SizedBox(height: 15.v),
          Divider(height: 1, color: appTheme.cardHairline),
          SizedBox(height: 15.v),
          Row(
            children: [
              Container(
                height: 24.v,
                padding: EdgeInsets.symmetric(horizontal: 10.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appTheme.paymentWash,
                  borderRadius: BorderRadius.circular(20.h),
                ),
                child: Text('7-day free trial',
                    style: CustomTextStyles.paymentChipPlain),
              ),
              const Spacer(),
              Text('-${controller.firstCharge}',
                  style: CustomTextStyles.paymentCredit),
            ],
          ),
          SizedBox(height: 15.v),
          Divider(height: 1, color: appTheme.cardHairline),
          SizedBox(height: 12.v),
          _Line(label: 'Subtotal', value: controller.firstCharge),
          SizedBox(height: 12.v),
          _Line(label: 'Sales tax', value: '₦0.00', info: true),
          SizedBox(height: 12.v),
          Divider(height: 1, color: appTheme.cardHairline),
          SizedBox(height: 14.v),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Total today', style: CustomTextStyles.paymentTotalLabel),
              const Spacer(),
              Text(controller.dueToday,
                  style: CustomTextStyles.paymentTotalAmount),
            ],
          ),
          SizedBox(height: 14.v),
          Row(
            children: [
              Expanded(
                child: Text(
                  'First charge on ${controller.firstChargeDate}',
                  style: CustomTextStyles.paymentFinePrint,
                ),
              ),
              Text(controller.firstCharge,
                  style: CustomTextStyles.paymentFirstCharge),
            ],
          ),
          SizedBox(height: 12.v),
          Divider(height: 1, color: appTheme.cardHairline),
          SizedBox(height: 8.v),
          Text(
            'This subscription auto-renews at ${controller.renewal} after '
            'your 7-day free trial. Cancel anytime in your account settings.',
            style: CustomTextStyles.paymentFinePrint,
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.info = false});

  final String label;
  final String value;
  final bool info;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: CustomTextStyles.paymentMuted),
        if (info) ...[
          SizedBox(width: 6.h),
          Container(
            height: 14.h,
            width: 14.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: appTheme.textPrimary.withValues(alpha: 0.72),
              shape: BoxShape.circle,
            ),
            child: Text('i', style: CustomTextStyles.paymentInfoGlyph),
          ),
        ],
        const Spacer(),
        Text(value, style: CustomTextStyles.paymentValue),
      ],
    );
  }
}

/// Apple Pay above, the card below, the chosen one outlined and — for the
/// card — carrying its form.
class _Methods extends StatelessWidget {
  const _Methods({required this.chosen});

  final PaymentMethod chosen;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrialOfferController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final method in PaymentMethod.values) ...[
          _MethodOption(
            method: method,
            chosen: chosen == method,
            onTap: () => controller.chooseMethod(method),
          ),
          if (method == PaymentMethod.card && chosen == PaymentMethod.card)
            const _CardForm(),
          if (method != PaymentMethod.values.last) SizedBox(height: 12.v),
        ],
      ],
    );
  }
}

class _MethodOption extends StatelessWidget {
  const _MethodOption({
    required this.method,
    required this.chosen,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool chosen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.h),
      child: Container(
        height: 58.v,
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        decoration: BoxDecoration(
          color: chosen ? appTheme.paymentWash : appTheme.surface,
          borderRadius: BorderRadius.circular(16.h),
          border: Border.all(
            color: chosen ? appTheme.soothifyBlue : appTheme.cardHairline,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 20.h,
              width: 20.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: chosen ? appTheme.soothifyBlue : appTheme.radioRim,
                  width: chosen ? 2 : 1.5,
                ),
              ),
              child: chosen
                  ? Container(
                      height: 10.h,
                      width: 10.h,
                      decoration: BoxDecoration(
                        color: appTheme.soothifyBlue,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.h),
            Expanded(
              child: Text(method.label,
                  style: CustomTextStyles.paymentMethodLabel),
            ),
            if (method == PaymentMethod.applePay)
              Row(
                children: [
                  Icon(Icons.apple, size: 20.h, color: appTheme.textPrimary),
                  Text('Pay', style: CustomTextStyles.paymentWallet),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// The card fields — Figma `311:25477` expands these under the chosen row.
class _CardForm extends StatelessWidget {
  const _CardForm();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12.v),
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: appTheme.soothifyBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Debit and credit cards accepted',
                    style: CustomTextStyles.paymentFinePrint),
              ),
              Text('VISA', style: CustomTextStyles.paymentVisa),
              SizedBox(width: 6.h),
              Text('mastercard', style: CustomTextStyles.paymentMastercard),
            ],
          ),
          SizedBox(height: 16.v),
          const _CardField(label: 'Cardholder name', hint: 'Name on card'),
          SizedBox(height: 16.v),
          const _CardField(
            label: 'Card number',
            hint: '1234 1234 1234 1234',
            keyboard: TextInputType.number,
          ),
          SizedBox(height: 16.v),
          Row(
            children: [
              const Expanded(
                child: _CardField(
                  label: 'Expiry date',
                  hint: 'MM / YY',
                  keyboard: TextInputType.datetime,
                ),
              ),
              SizedBox(width: 12.h),
              const Expanded(
                child: _CardField(
                  label: 'Security code',
                  hint: 'CVC',
                  keyboard: TextInputType.number,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.v),
          Row(
            children: [
              Icon(Icons.lock_outline, size: 12.h,
                  color: appTheme.textSecondary),
              SizedBox(width: 6.h),
              Expanded(
                child: Text('Your card details are encrypted and secure.',
                    style: CustomTextStyles.paymentFinePrint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  const _CardField({
    required this.label,
    required this.hint,
    this.keyboard,
  });

  final String label;
  final String hint;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: CustomTextStyles.paymentFieldLabel),
        SizedBox(height: 8.v),
        Container(
          height: 46.v,
          padding: EdgeInsets.symmetric(horizontal: 12.h),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: appTheme.surface,
            borderRadius: BorderRadius.circular(8.h),
            border: Border.all(color: appTheme.fieldRim),
          ),
          child: TextField(
            keyboardType: keyboard,
            style: CustomTextStyles.paymentValue,
            cursorColor: appTheme.soothifyBlue,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: hint,
              hintStyle: CustomTextStyles.paymentHint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _PromoRow extends StatelessWidget {
  const _PromoRow();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrialOfferController>();
    return Container(
      height: 46.v,
      padding: EdgeInsets.symmetric(horizontal: 12.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.cardHairline),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => controller.promo.value = v,
              style: CustomTextStyles.paymentValue,
              cursorColor: appTheme.soothifyBlue,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'Enter promo code',
                hintStyle: CustomTextStyles.paymentHint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          InkWell(
            onTap: controller.applyPromo,
            child: Text('Apply', style: CustomTextStyles.paymentApply),
          ),
        ],
      ),
    );
  }
}
