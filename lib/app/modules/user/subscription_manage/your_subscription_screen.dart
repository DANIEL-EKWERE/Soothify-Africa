import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/membership.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_ghost_button.dart';
import '../settings/widgets/settings_header.dart';
import 'controller/subscription_manage_controller.dart';
import 'widgets/subscription_pieces.dart';

/// "Your Subscription" — Figma `308:25746` (inactive) and `308:25763`
/// (active), with the cancellation card from `308:25807` raised over it.
///
/// Measured below the status bar: title 65, card at 24 across 342 with a 16
/// radius inside a 5% black hairline, its badge at (24, 24) within the card,
/// headline at 80, and the action 240 down.
///
/// This replaces the older `259:37602`, which was a single "You are not
/// subscribed" screen. That frame is the inactive state here, redrawn.
class YourSubscriptionScreen extends GetView<SubscriptionManageController> {
  const YourSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SettingsHeader(title: 'Your Subscription'),
            SizedBox(height: 38.v),
            Expanded(
              // Every observable is read here, inside the builder. Reading
              // them in the child instead leaves this Obx with nothing to
              // watch, which GetX reports as "improper use" and then does not
              // rebuild.
              child: Obx(() {
                final active = controller.isActive;
                final plan = controller.plan.value;
                final status = controller.statusLabel;
                final renewal = controller.renewalCopy;
                return ListView(
                  padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 32.v),
                  children: [
                    if (active)
                      _ActiveCard(
                        plan: plan,
                        status: status,
                        renewal: renewal,
                      )
                    else
                      const _InactiveCard(),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nothing running: the pitch, the trial button, and a way to the receipts.
class _InactiveCard extends StatelessWidget {
  const _InactiveCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionManageController>();
    return SubscriptionCard(
      children: [
        const StatusBadge(label: 'Inactive', live: false),
        SizedBox(height: 32.v),
        Text(
          'You currently don’t have an active subscription.',
          style: CustomTextStyles.subscriptionHeadline,
        ),
        SizedBox(height: 16.v),
        Text(
          'Unlock unlimited access to all expert-led yoga & Pilates classes, '
          'offline streaming, and daily wellness micro-routines.',
          style: CustomTextStyles.subscriptionBody,
        ),
        SizedBox(height: 32.v),
        CustomElevatedButton(
          text: 'Start 7-Day Free Trial',
          onPressed: controller.startTrial,
        ),
        SizedBox(height: 40.v),
        Center(
          child: InkWell(
            onTap: controller.openBillingHistory,
            child: Text(
              'View past receipts',
              style: CustomTextStyles.subscriptionLink,
            ),
          ),
        ),
      ],
    );
  }
}

/// Running: what is being paid, on what card, and the two ways out of it.
class _ActiveCard extends StatelessWidget {
  const _ActiveCard({
    required this.plan,
    required this.status,
    required this.renewal,
  });

  final MembershipPlan plan;
  final String status;
  final String renewal;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionManageController>();
    return SubscriptionCard(
      children: [
        StatusBadge(label: status, live: true),
        SizedBox(height: 32.v),
        Text(
          'Subscription details',
          style: CustomTextStyles.subscriptionHeadline,
        ),
        SizedBox(height: 8.v),
        Text(renewal, style: CustomTextStyles.subscriptionBody),
        SizedBox(height: 32.v),
        Text(plan.brandedName,
            style: CustomTextStyles.subscriptionPlanName),
        SizedBox(height: 8.v),
        Text(plan.billed, style: CustomTextStyles.subscriptionPlanPrice),
        SizedBox(height: 32.v),
        Text('Payment Method', style: CustomTextStyles.subscriptionLabel),
        SizedBox(height: 8.v),
        Text(controller.card, style: CustomTextStyles.subscriptionValue),
        SizedBox(height: 4.v),
        InkWell(
          onTap: controller.updatePaymentMethod,
          child: Text('Update', style: CustomTextStyles.subscriptionLink),
        ),
        SizedBox(height: 31.v),
        CustomGhostButton(
          text: 'Change Plan',
          onPressed: controller.openChangePlan,
        ),
        SizedBox(height: 16.v),
        Center(
          child: InkWell(
            onTap: () => CancelSubscriptionCard.show(context),
            child: Text(
              'Cancel Subscription',
              style: CustomTextStyles.subscriptionDestructive,
            ),
          ),
        ),
      ],
    );
  }
}
