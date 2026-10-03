import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_ghost_button.dart';
import 'controller/settings_controller.dart';
import 'widgets/settings_header.dart';

/// "Manage subscription" — Figma `259:37602`.
///
/// Measured below the status bar: heading 148 centred over two lines, body
/// 216 across 342, the ghost button at 422 and 52 tall.
///
/// The frame draws only the unsubscribed state. Nothing tracks a subscription
/// yet, so that is the only state built; when one exists this screen gains
/// the plan, its renewal date and a way to cancel.
class ManageSubscriptionScreen extends GetView<SettingsController> {
  const ManageSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SettingsHeader(title: 'Manage subscription'),
            SizedBox(height: 41.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: Text(
                'You are not subscribed',
                textAlign: TextAlign.center,
                style: CustomTextStyles.settingsPageHeading,
              ),
            ),
            SizedBox(height: 24.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: Text(
                'You have free Soothify account. You can purchase a Soothify '
                'Pro subscription to access our our library of content and '
                'features.',
                style: CustomTextStyles.settingsPageBody,
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: CustomGhostButton(
                text: 'Unlock Soothify Pro',
                onPressed: controller.openPlans,
              ),
            ),
            SizedBox(height: 56.v),
          ],
        ),
      ),
    );
  }
}
