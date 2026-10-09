import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/custom_elevated_button.dart';
import '../controller/subscription_manage_controller.dart';

/// The white card every subscription screen is built on — 342 wide, 16
/// radius, a 5% black hairline, 24 of padding all round.
class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: appTheme.cardHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// "Inactive" or "Active · Free Trial" — a pill at the card's top left.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.live});

  final String label;

  /// Green when something is running, grey when nothing is.
  final bool live;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        // No height and no alignment: either makes a Container fill the
        // width it is offered, and the Align around it passes that width
        // straight through — so the pill ran the whole card instead of
        // hugging its own label.
        padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 5.v),
        decoration: BoxDecoration(
          color: live
              ? appTheme.statusLiveInk.withValues(alpha: 0.26)
              : appTheme.statusIdleFill,
          borderRadius: BorderRadius.circular(16.h),
        ),
        child: Text(
          label,
          style: CustomTextStyles.subscriptionBadge.copyWith(
            color: live ? appTheme.statusLiveInk : appTheme.statusIdleInk,
          ),
        ),
      ),
    );
  }
}

/// "Are you sure you want to cancel?" — Figma `308:25807`, which draws it as
/// a card over the active screen behind a 16% black scrim.
///
/// The filled button is the one that keeps the subscription; confirming is a
/// plain link under it. That asymmetry is the design's, and it is the right
/// way round for something irreversible.
class CancelSubscriptionCard extends StatelessWidget {
  const CancelSubscriptionCard({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.16),
        builder: (_) => const CancelSubscriptionCard(),
      );

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionManageController>();
    return Dialog(
      backgroundColor: appTheme.surface,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Are you sure you want to cancel?',
              style: CustomTextStyles.subscriptionHeadline,
            ),
            SizedBox(height: 16.v),
            Text(
              'You will lose access to your daily streaks, custom wellness '
              'history, and unlimited classes when your current period ends '
              'on ${controller.renewalDate}. Until then, you keep full '
              'access.',
              style: CustomTextStyles.subscriptionBody,
            ),
            SizedBox(height: 32.v),
            CustomElevatedButton(
              text: 'Keep My Subscription',
              onPressed: controller.keepSubscription,
            ),
            SizedBox(height: 22.v),
            Center(
              child: InkWell(
                onTap: controller.confirmCancellation,
                child: Text(
                  'Confirm Cancellation',
                  style: CustomTextStyles.subscriptionQuietLink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
