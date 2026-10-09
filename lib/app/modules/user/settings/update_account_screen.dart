import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_ghost_button.dart';
import '../../../widgets/filled_text_field.dart';
import 'controller/settings_controller.dart';
import 'widgets/settings_header.dart';

/// "Update Account" — what Account Settings' "Edit Account Details" opens.
///
/// One field: the name. The portrait is changed on User Profile, which the
/// avatar in Settings opens, so this screen does not repeat it.
///
/// Measured below the status bar: the lead at 92, the "Name" caption at 152,
/// its field at 173 (49 tall) and the action at 294, 50 tall.
class UpdateAccountScreen extends GetView<SettingsController> {
  const UpdateAccountScreen({super.key});

  static const String lead = 'Update your Account Details';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SettingsHeader(title: 'Update Account'),
            SizedBox(height: 33.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: Text(lead, style: CustomTextStyles.updateAccountLead),
            ),
            SizedBox(height: 39.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: FilledTextField(
                label: 'Name',
                controller: controller.name,
                textCapitalization: TextCapitalization.words,
                hintText: controller.firstName,
              ),
            ),
            SizedBox(height: 50.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: CustomGhostButton(
                text: 'Update',
                onPressed: controller.updateAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
