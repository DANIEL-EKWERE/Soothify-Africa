import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/bank_destination.dart';
import '../../../data/models/payout_method.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../widgets/expert_header.dart';
import 'controller/payout_controller.dart';
import '../../../widgets/soothify_word.dart';

/// Choosing where the money goes — Figma "Payout method" (`259:59463`, filed
/// in the file under the name "Recent payouts").
///
/// Measured: the title at 70, the blurb at 117, three 342x112 cards from 193
/// at a 128 pitch with a 36 disc inset 17, the Paystack panel 342x94 at 593
/// filled `#34C759` at 8%, and "Proceed" at 727.
class ExpertPayoutMethodScreen extends GetView<PayoutController> {
  const ExpertPayoutMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        // Two states in one frame set: the chooser until a destination has
        // been added, then the card showing what is on file.
        child: Obx(
          () => controller.hasDestination
              ? const _SavedDestination()
              : const _Chooser(),
        ),
      ),
    );
  }
}

/// What the screen shows once a destination is on file — Figma's populated
/// "Payout method". This is also where the Earnings card's edit pencil, the
/// one beside "Bank ****…", lands.
class _SavedDestination extends GetView<PayoutController> {
  const _SavedDestination();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 33.v),
        const ExpertHeader(title: 'Payout method'),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(24.h, 25.v, 24.h, 24.v),
            children: [
              // The frame sets this heading at 20, a step above the section
              // headings elsewhere — it is the screen's own title.
              Text('Payout Method',
                  style: CustomTextStyles.expertSection
                      .copyWith(fontSize: 20.fSize)),
              SizedBox(height: 8.v),
              Text(
                'This is where your earnings will be sent. You can edit your '
                'details anytime.',
                style: CustomTextStyles.expertBlurb,
              ),
              SizedBox(height: 32.v),
              // One card per account: the frame draws a single Access Bank
              // row, but the withdrawal screen's three tiles are three of
              // these, and they are edited from here.
              Obx(
                () => Column(
                  children: [
                    for (var i = 0; i < controller.destinations.length; i++)
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.v),
                        child: _DestinationCard(
                          destination: controller.destinations[i],
                          onEdit: () => controller.editDestination(i),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 8.v),
              const Assurance(),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 12.v),
          child: SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: controller.addDestination,
              borderRadius: BorderRadius.circular(8.h),
              child: Container(
                height: 52.v,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.h),
                  border: Border.all(color: appTheme.soothifyBlue),
                ),
                child: Text('+  Add New Payout Method',
                    style: CustomTextStyles.subscribeLabel
                        .copyWith(color: appTheme.soothifyBlue)),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 25.v),
          child: CustomElevatedButton(
            text: 'Back to Earnings',
            onPressed: Get.back,
          ),
        ),
      ],
    );
  }
}

/// One account on file: the bank, the number, the name on it, an Active chip
/// and the pencil that reopens the form on this account.
class _DestinationCard extends StatelessWidget {
  const _DestinationCard({required this.destination, required this.onEdit});

  final BankDestination destination;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.h,
            height: 36.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: appTheme.textPrimary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_balance,
                size: 18.h, color: appTheme.textPrimary),
          ),
          SizedBox(width: 16.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bank Transfer (NGN)',
                    style: CustomTextStyles.expertCardMeta),
                SizedBox(height: 6.v),
                Text(destination.bank,
                    style: CustomTextStyles.expertOutcomeTitle),
                SizedBox(height: 6.v),
                Text(destination.accountNumber,
                    style: CustomTextStyles.expertRowLabel),
                SizedBox(height: 6.v),
                Text(destination.accountName,
                    style: CustomTextStyles.expertRowLabel),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.h, vertical: 5.v),
                decoration: BoxDecoration(
                  color: appTheme.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.h),
                ),
                child: Text('Active',
                    style: CustomTextStyles.expertCardMeta
                        .copyWith(color: appTheme.success)),
              ),
              SizedBox(height: 16.v),
              InkWell(
                onTap: onEdit,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 27.h,
                  height: 27.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: appTheme.statusIdleFill,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit_outlined,
                      size: 15.h, color: appTheme.textPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Choosing how to be paid, before anything is on file.
class _Chooser extends GetView<PayoutController> {
  const _Chooser();

  @override
  Widget build(BuildContext context) {
    return Column(
          children: [
            SizedBox(height: 33.v),
            const ExpertHeader(title: 'Payout method'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 25.v, 24.h, 24.v),
                children: [
                  SoothifyText(
                    // The frame drops a verb: "Choose how you'd like to your
                    // payments from Soothify."
                    'Choose how you’d like to receive your payments from '
                    'Soothify.',
                    style: CustomTextStyles.expertBlurb,
                  ),
                  SizedBox(height: 32.v),
                  Obx(
                    () => Column(
                      children: [
                        for (final method in PayoutMethod.offered) ...[
                          _MethodCard(
                            method: method,
                            selected: controller.method.value == method,
                          ),
                          SizedBox(height: 16.v),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 16.v),
                  const Assurance(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 25.v),
              child: CustomElevatedButton(
                text: 'Proceed',
                onPressed: controller.proceed,
              ),
            ),
          ],
        );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({required this.method, required this.selected});

  final PayoutMethod method;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PayoutController>();
    return GestureDetector(
      onTap: () => controller.choose(method),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 112.v,
        padding: EdgeInsets.symmetric(horizontal: 17.h),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(
            color: selected ? appTheme.soothifyBlue : appTheme.cardRim,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 25.v),
              child: Container(
                width: 36.h,
                height: 36.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appTheme.textPrimary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(method.glyph,
                    size: 18.h, color: appTheme.textPrimary),
              ),
            ),
            SizedBox(width: 16.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 25.v),
                  Text(method.label,
                      style: CustomTextStyles.payoutMethodTitle),
                  SizedBox(height: 8.v),
                  Text(
                    method.blurb,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles.payoutMethodBody,
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

/// The green panel naming who processes the payment.
/// The green Paystack note both payout screens end on.
class Assurance extends StatelessWidget {
  const Assurance({super.key});

  @override
  Widget build(BuildContext context) {
    // A shield at the left with the words beside it, both ranged left — the
    // frame's own arrangement. This was centred, with no shield at all, and
    // carried a near-black outline the frame does not draw.
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.h, 18.v, 16.h, 18.v),
      decoration: BoxDecoration(
        color: appTheme.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.h),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 20.h, color: appTheme.success),
          SizedBox(width: 12.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // The frame writes "All payment are processed securely by
                  // Paystack."
                  'All payments are processed securely by Paystack.',
                  style: CustomTextStyles.payoutAssurance,
                ),
                SizedBox(height: 10.v),
                Text('paystack', style: CustomTextStyles.payoutProcessor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
