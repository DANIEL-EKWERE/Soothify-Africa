import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/user_role.dart';
import '../../../widgets/custom_elevated_button.dart';
import 'controller/role_select_controller.dart';

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
              Text('Welcome', style: theme.textTheme.displaySmall),
              SizedBox(height: 8.v),
              Text(
                'How will you be using Soothify Africa?',
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              CustomElevatedButton(
                text: 'I am here to listen',
                onPressed: () => controller.choose(UserRole.user),
              ),
              SizedBox(height: 12.v),
              CustomElevatedButton(
                text: 'I am a practitioner',
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
