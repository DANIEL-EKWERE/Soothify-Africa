import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/filled_text_field.dart';
import '../../../widgets/google_button.dart';
import 'controller/signup_controller.dart';
import 'widgets/password_rule_chip.dart';

/// Create Account — Figma 655:6096 (empty) and 655:6183 (filled).
///
/// Positions inside the 390x844 frame: heading at 80 with a 24px mark at its
/// right, blurb at 114, then Fullname / Email / Password / Confirm as caption
/// plus 344x48 filled box, the three password chips at 466, Create Account at
/// 669 and Continue with Google at 745.
class SignupScreen extends GetView<SignupController> {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.h, 33.h, 24.h, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Create your account',
                      style: CustomTextStyles.authHeading,
                    ),
                  ),
                  Image.asset(
                    ImageConstant.imgAuthHeaderIcon,
                    height: 24.h,
                    width: 24.h,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Rest assured that your personal information is securely '
                'protected and never shared with third parties.',
                style: CustomTextStyles.authBlurb,
              ),
              SizedBox(height: 24.h),
              FilledTextField(
                label: 'Fullname',
                controller: controller.fullnameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (v) => controller.fullname.value = v,
              ),
              SizedBox(height: 24.h),
              FilledTextField(
                label: 'Email Address',
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) => controller.email.value = v,
              ),
              SizedBox(height: 24.h),
              Obx(
                () => FilledTextField(
                  label: 'Password',
                  controller: controller.passwordController,
                  obscureText: controller.obscurePassword.value,
                  onChanged: (v) => controller.password.value = v,
                  suffix: _ObscureToggle(
                    isObscured: controller.obscurePassword.value,
                    onTap: controller.toggleObscurePassword,
                  ),
                ),
              ),
              SizedBox(height: 17.h),
              Obx(
                () => Wrap(
                  // The parent Column stretches its children, so the chips
                  // need an explicit start alignment to size to their text.
                  alignment: WrapAlignment.start,
                  spacing: 8.h,
                  runSpacing: 8.h,
                  children: [
                    for (final rule in PasswordRule.values)
                      PasswordRuleChip(
                        label: rule.label,
                        isMet: controller.ruleMet(rule),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Obx(
                () => FilledTextField(
                  label: 'Confirm password',
                  controller: controller.confirmController,
                  obscureText: controller.obscureConfirm.value,
                  onChanged: (v) => controller.confirm.value = v,
                  hasError: controller.confirm.value.isNotEmpty &&
                      !controller.confirmMatches,
                  suffix: _ObscureToggle(
                    isObscured: controller.obscureConfirm.value,
                    onTap: controller.toggleObscureConfirm,
                  ),
                ),
              ),
              Obx(
                () => controller.confirm.value.isNotEmpty &&
                        !controller.confirmMatches
                    ? Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          'Passwords do not match.',
                          style: CustomTextStyles.inlineError,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(height: 40.h),
              Obx(
                () => CustomElevatedButton(
                  text: 'Create Account',
                  isLoading: controller.isLoading.value,
                  isEnabled: controller.canSubmit,
                  onPressed: controller.submit,
                ),
              ),
              SizedBox(height: 24.h),
              GoogleButton(onPressed: controller.continueWithGoogle),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: controller.goToSignIn,
                child: Text(
                  'Already have an account? Log in',
                  style: CustomTextStyles.authFooter,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ObscureToggle extends StatelessWidget {
  const _ObscureToggle({required this.isObscured, required this.onTap});

  final bool isObscured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20.h,
        color: appTheme.hintText,
      ),
    );
  }
}
