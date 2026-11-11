import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/user_role.dart';
import '../../../widgets/custom_elevated_button.dart';
import 'controller/role_select_controller.dart';
import '../../../widgets/soothify_word.dart';

class RoleSelectScreen extends GetView<RoleSelectController> {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 32.v),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text('auth.welcome'.tr, style: theme.textTheme.displaySmall),
              SizedBox(height: 8.v),
              SoothifyText(
                'auth.roleQuestion'.tr,
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              CustomElevatedButton(
                text: 'auth.roleListen'.tr,
                onPressed: () => controller.choose(UserRole.user),
              ),
              SizedBox(height: 12.v),
              CustomElevatedButton(
                text: 'auth.rolePractitioner'.tr,
                style: CustomButtonStyles.secondary,
                onPressed: () => controller.choose(UserRole.practitioner),
              ),
              SizedBox(height: 16.v),
            ],
          ),
        ),
      ),
    );
  }
}
