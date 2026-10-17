import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/filled_text_field.dart';
import '../../../widgets/gradient_text.dart';
import '../../../widgets/soothify_word.dart';
import 'controller/forgot_password_controller.dart';

/// Resetting a forgotten password.
///
/// The design has no frame for this, so it is built from Log in
/// (`1704:12254`): the same 24pt gutters, heading, blurb, filled fields and
/// single action, with the inline error in the place that screen keeps for
/// it. Worth re-measuring if a frame is ever drawn.
class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      appBar: AppBar(
        backgroundColor: appTheme.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 28.h, color: appTheme.authHeading),
          onPressed: Get.back,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.h, 8.h, 24.h, 32.h),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: controller.step.value == ResetStep.askForEmail
                  ? _askForEmail(context)
                  : _enterCode(context),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _askForEmail(BuildContext context) => [
        Text('Reset your password', style: CustomTextStyles.authHeading),
        SizedBox(height: 8.h),
        SoothifyText(
          'We will email you a six-digit code.',
          style: CustomTextStyles.authBlurb,
        ),
        SizedBox(height: 32.h),
        FilledTextField(
          label: 'Email Address',
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          hasError: controller.errorText.value != null,
          onChanged: (v) {
            controller.email.value = v;
            controller.errorText.value = null;
          },
        ),
        SizedBox(height: 16.h),
        _error(),
        SizedBox(height: 40.h),
        CustomElevatedButton(
          text: 'Send the code',
          isLoading: controller.isLoading.value,
          isEnabled: controller.canSend,
          onPressed: controller.sendCode,
        ),
      ];

  List<Widget> _enterCode(BuildContext context) => [
        Text('Enter the code', style: CustomTextStyles.authHeading),
        SizedBox(height: 8.h),
        // The server's own wording, which does not say whether the address
        // has an account — and neither should this screen.
        SoothifyText(
          controller.sentMessage.value ?? '',
          style: CustomTextStyles.authBlurb,
        ),
        SizedBox(height: 32.h),
        FilledTextField(
          label: 'Six-digit code',
          controller: controller.codeController,
          keyboardType: TextInputType.number,
          hasError: controller.errorText.value != null,
          onChanged: (v) {
            controller.code.value = v;
            controller.errorText.value = null;
          },
        ),
        SizedBox(height: 24.h),
        FilledTextField(
          label: 'New password',
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
        SizedBox(height: 16.h),
        _error(),
        SizedBox(height: 40.h),
        CustomElevatedButton(
          text: 'Set my password',
          isLoading: controller.isLoading.value,
          isEnabled: controller.canReset,
          onPressed: controller.reset,
        ),
        SizedBox(height: 24.h),
        Center(
          child: GestureDetector(
            onTap: controller.startAgain,
            child: GradientText(
              'Send another code',
              gradient: appTheme.titleGradient,
              style: CustomTextStyles.authFooter,
            ),
          ),
        ),
      ];

  Widget _error() => controller.errorText.value == null
      ? const SizedBox.shrink()
      : Text(
          controller.errorText.value!,
          style: CustomTextStyles.inlineError,
        );
}
