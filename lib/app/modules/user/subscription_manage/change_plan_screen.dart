import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/membership.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_ghost_button.dart';
import '../settings/widgets/settings_header.dart';
import 'controller/subscription_manage_controller.dart';

/// "Change Your Plan" — Figma `308:25888`.
///
/// Measured below the status bar: title 65, subtitle 127, the annual option
/// at 185 (342x160, outlined in the brand blue at 1.5 when chosen), the
/// monthly one at 357 (342x122), the proration notice at 499, and the two
/// actions at 631 and 691.
class ChangePlanScreen extends GetView<SubscriptionManageController> {
  const ChangePlanScreen({super.key});

  static const String proration =
      'When you switch plans, the remaining value of your current billing '
      'period will be automatically credited toward your new plan. Your '
      'billing date will update accordingly.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SettingsHeader(title: 'Change Your Plan'),
            SizedBox(height: 38.v),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 32.v),
                children: [
                  Text(
                    'Choose the billing rhythm that works best for your '
                    'practice.',
                    style: CustomTextStyles.subscriptionBody,
                  ),
                  SizedBox(height: 20.v),
                  for (final plan in MembershipPlan.values) ...[
                    // Both observables are read in the builder, not in
                    // _PlanOption, or this Obx watches nothing.
                    Obx(() => _PlanOption(
                          plan: plan,
                          chosen: controller.choice.value == plan,
                          current: controller.plan.value == plan,
                        )),
                    SizedBox(height: 12.v),
                  ],
                  SizedBox(height: 8.v),
                  Container(
                    padding: EdgeInsets.all(16.h),
                    decoration: BoxDecoration(
                      color: appTheme.surface,
                      borderRadius: BorderRadius.circular(16.h),
                      border: Border.all(color: appTheme.cardHairline),
                    ),
                    child: Text(
                      proration,
                      style: CustomTextStyles.subscriptionNotice,
                    ),
                  ),
                  SizedBox(height: 20.v),
                  CustomElevatedButton(
                    text: 'Confirm Plan Change',
                    onPressed: controller.confirmPlanChange,
                  ),
                  SizedBox(height: 8.v),
                  CustomGhostButton(text: 'Cancel', onPressed: Get.back),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanOption extends StatelessWidget {
  const _PlanOption({
    required this.plan,
    required this.chosen,
    required this.current,
  });

  final MembershipPlan plan;
  final bool chosen;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionManageController>();
    return InkWell(
      onTap: () => controller.choose(plan),
      borderRadius: BorderRadius.circular(16.h),
      child: Container(
        padding: EdgeInsets.all(20.h),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(16.h),
          border: Border.all(
            color: chosen ? appTheme.soothifyBlue : appTheme.cardHairline,
            width: chosen ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (plan.hasSaving) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  // No height and no alignment: either makes a Container
                  // fill the width it is offered, which had the pill running
                  // the whole card instead of hugging its own label.
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.h, vertical: 5.v),
                  decoration: BoxDecoration(
                    color: appTheme.brandWash,
                    borderRadius: BorderRadius.circular(16.h),
                  ),
                  child: Text(
                    plan.saving,
                    style: CustomTextStyles.subscriptionBadge
                        .copyWith(color: appTheme.soothifyBlue),
                  ),
                ),
              ),
              SizedBox(height: 12.v),
            ],
            Text(plan.name, style: CustomTextStyles.subscriptionPlanName),
            SizedBox(height: 8.v),
            Text(plan.perMonth, style: CustomTextStyles.subscriptionHeadline),
            if (plan.cadence.isNotEmpty) ...[
              SizedBox(height: 8.v),
              Text(plan.cadence, style: CustomTextStyles.subscriptionCadence),
            ],
            if (current) ...[
              SizedBox(height: 8.v),
              Text(
                'Current plan',
                style: CustomTextStyles.subscriptionBadge
                    .copyWith(color: appTheme.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
