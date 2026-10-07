import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_ghost_button.dart';
import 'controller/settings_controller.dart';
import 'widgets/settings_header.dart';

/// "Delete Account" — redrawn by the designer on 2026-10-07.
///
/// It asks rather than warns: a question, what will be lost, and two answers.
/// Keeping the account is the outlined one and comes first, so the destructive
/// answer is neither the default nor the easier reach.
///
/// Measured below the status bar: the question at 105, the body from 131 on a
/// 24 pitch, and the two actions at 429 and 496, both 52 tall.
class DeleteAccountScreen extends GetView<SettingsController> {
  const DeleteAccountScreen({super.key});

  static const String lead = 'Delete your account?';

  static const String warning =
      'This will permanently erase your profile, saved classes, and active '
      'subscription. This action cannot be undone.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SettingsHeader(title: 'Delete Account'),
            SizedBox(height: 46.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: Text(lead, style: CustomTextStyles.deleteAccountLead),
            ),
            SizedBox(height: 18.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: Text(warning, style: CustomTextStyles.deleteAccountBody),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: CustomGhostButton(
                text: 'Cancel, keep my account',
                onPressed: Get.back,
              ),
            ),
            SizedBox(height: 15.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: CustomElevatedButton(
                text: 'Yes, delete Account',
                onPressed: controller.confirmDeleteAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: appTheme.destructiveFill,
                  foregroundColor: appTheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.h),
                  ),
                ),
              ),
            ),
            SizedBox(height: 56.v),
          ],
        ),
      ),
    );
  }
}
