import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_ghost_button.dart';
import 'controller/settings_controller.dart';
import 'widgets/settings_header.dart';

/// "Delete Account" — Figma `259:37617`.
///
/// Measured below the status bar: the lead line at 131, the warning at 183
/// across 342, and the ghost button at 470.
class DeleteAccountScreen extends GetView<SettingsController> {
  const DeleteAccountScreen({super.key});

  static const String lead = 'We’re sorry to see you go.';

  static const String warning =
      'Deleting your account is irreversible and means that you will no '
      'longer be able to access your session history, stats, favorites, and '
      'more.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SettingsHeader(title: 'Delete Account'),
            SizedBox(height: 24.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 23.h),
              child: Text(lead, style: CustomTextStyles.settingsPageBody),
            ),
            SizedBox(height: 28.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 23.h),
              child: Text(warning, style: CustomTextStyles.settingsPageBody),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 23.h),
              child: CustomGhostButton(
                text: 'Delete Account',
                onPressed: controller.confirmDeleteAccount,
              ),
            ),
            SizedBox(height: 56.v),
          ],
        ),
      ),
    );
  }
}
