import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/settings_entry.dart';
import 'controller/settings_controller.dart';
import 'widgets/settings_header.dart';

/// "Account Settings" — Figma `259:37589`.
///
/// Two rows with a glyph each: "Edit Account Details" at 131 and "Delete
/// Account" at 191, both 44 tall against a 246 label box.
class AccountSettingsScreen extends GetView<SettingsController> {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SettingsHeader(title: 'Account Settings'),
            SizedBox(height: 24.v),
            _Row(
              // The frame draws the same person glyph the Settings list uses
              // for Account.
              leading: CustomImageView(
                imagePath: SettingsEntry.account.asset,
                height: 24.h,
                width: 24.h,
                color: appTheme.textPrimary,
              ),
              label: 'Edit Account Details',
              onTap: controller.openEditAccount,
            ),
            SizedBox(height: 16.v),
            _Row(
              // No bin was exported with the Settings glyphs, so this is
              // Material's.
              leading: Icon(Icons.delete_outline,
                  size: 24.h, color: appTheme.textPrimary),
              label: 'Delete Account',
              onTap: controller.openDeleteAccount,
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.leading,
    required this.label,
    required this.onTap,
  });

  final Widget leading;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 10.v),
        child: Row(
          children: [
            leading,
            SizedBox(width: 16.h),
            Expanded(
              child: Text(label, style: CustomTextStyles.settingsRowLabel),
            ),
          ],
        ),
      ),
    );
  }
}
