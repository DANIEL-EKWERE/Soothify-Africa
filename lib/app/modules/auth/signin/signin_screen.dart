import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/filled_text_field.dart';
import '../../../widgets/google_button.dart';
import '../../../widgets/gradient_text.dart';
import 'controller/signin_controller.dart';

/// Log in — Figma 1704:12254, with the error state from 1704:12316.
///
/// Positions inside the 390x844 frame: heading at 80, blurb at 113, Email at
/// 173, Password at 270, the forgotten-password link (or the error message,
/// which replaces it) at 359, Proceed at 447, Continue with Google at 523 and
/// the sign-up footer at 591.
class SigninScreen extends GetView<SigninController> {
  const SigninScreen({super.key});

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
                      'Log in to your account',
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
                'Welcome back to SoothifyAfrica!',
                style: CustomTextStyles.authBlurb,
              ),
              SizedBox(height: 32.h),
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
                  hasError: controller.errorText.value != null,
                  onChanged: (v) {
                    controller.password.value = v;
                    controller.errorText.value = null;
                  },
                  suffix: GestureDetector(
                    onTap: controller.toggleObscure,
                    child: Icon(
                      controller.obscurePassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20.h,
                      color: appTheme.hintText,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // The design puts the error exactly where the forgotten-password
              // link sits, so one replaces the other rather than shifting the
              // layout.
              Obx(
                () => controller.errorText.value != null
                    ? Text(
                        controller.errorText.value!,
                        style: CustomTextStyles.inlineError,
                      )
                    : GestureDetector(
                        onTap: controller.forgotPassword,
                        child: GradientText(
                          'Have you forgotten password?',
                          gradient: appTheme.titleGradient,
                          style: CustomTextStyles.authFooter,
                        ),
                      ),
              ),
              SizedBox(height: 55.h),
              Obx(
                () => CustomElevatedButton(
                  text: 'Proceed',
                  isLoading: controller.isLoading.value,
                  isEnabled: controller.canSubmit,
                  onPressed: controller.submit,
                ),
              ),
              SizedBox(height: 24.h),
              GoogleButton(onPressed: controller.continueWithGoogle),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: controller.goToSignUp,
                child: Text(
                  'Don’t have an account? Sign up',
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
