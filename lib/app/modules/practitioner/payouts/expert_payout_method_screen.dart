import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/payout_method.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../widgets/expert_header.dart';
import 'controller/payout_controller.dart';

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
        child: Column(
          children: [
            SizedBox(height: 33.v),
            const ExpertHeader(title: 'Payout method'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 25.v, 24.h, 24.v),
                children: [
                  Text(
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
                        for (final method in PayoutMethod.values) ...[
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
                  const _Assurance(),
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
        ),
      ),
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
            color: selected ? appTheme.soothifyBlue : appTheme.textPrimary,
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
                decoration: BoxDecoration(
                  color: appTheme.textPrimary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
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
class _Assurance extends StatelessWidget {
  const _Assurance();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 94.v,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      decoration: BoxDecoration(
        color: appTheme.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.textPrimary),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            // The frame writes "All payment are processed securely by
            // Paystack."
            'All payments are processed securely by Paystack.',
            textAlign: TextAlign.center,
            style: CustomTextStyles.payoutAssurance,
          ),
          SizedBox(height: 18.v),
          Text('paystack', style: CustomTextStyles.payoutProcessor),
        ],
      ),
    );
  }
}
