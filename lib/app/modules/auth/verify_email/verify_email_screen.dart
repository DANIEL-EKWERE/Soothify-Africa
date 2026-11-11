import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/filled_text_field.dart';
import '../../../widgets/gradient_text.dart';
import '../../../widgets/soothify_word.dart';
import 'controller/verify_email_controller.dart';

/// Confirming the address a password sign-up was made with.
///
/// The design has no frame for this, so it is built from Reset your password
/// — itself built from Log in (`1704:12254`): the same 24pt gutters,
/// heading, blurb, one filled field and single action, with the inline
/// error in the place that screen keeps for it. Worth re-measuring if a
/// frame is ever drawn.
///
/// No back chevron. Going back would leave the app signed in as an account
/// that has not confirmed its address; "Use a different email" signs out
/// and returns to Log in, which is the honest version of the same wish.
class VerifyEmailScreen extends GetView<VerifyEmailController> {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.h, 48.h, 24.h, 32.h),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('auth.confirmEmailTitle'.tr, style: CustomTextStyles.authHeading),
                SizedBox(height: 8.h),
                SoothifyText(
                  controller.email.value.isEmpty
                      ? 'auth.codeSentBlurb'.tr
                      : 'We sent a six-digit code to '
                          '${controller.email.value}. Enter it below.',
                  style: CustomTextStyles.authBlurb,
                ),
                SizedBox(height: 32.h),
                FilledTextField(
                  label: 'auth.sixDigitCode'.tr,
                  controller: controller.codeController,
                  keyboardType: TextInputType.number,
                  hasError: controller.errorText.value != null,
                  onChanged: (v) {
                    controller.code.value = v;
                    controller.errorText.value = null;
                  },
                ),
                SizedBox(height: 16.h),
                if (controller.errorText.value != null)
                  Text(
                    controller.errorText.value!,
                    style: CustomTextStyles.inlineError,
                  )
                else if (controller.sentMessage.value != null)
                  SoothifyText(
                    controller.sentMessage.value!,
                    style: CustomTextStyles.authBlurb,
                  ),
                SizedBox(height: 40.h),
                CustomElevatedButton(
                  text: 'auth.confirmMyEmail'.tr,
                  isLoading: controller.isLoading.value,
                  isEnabled: controller.canVerify,
                  onPressed: controller.verify,
                ),
                SizedBox(height: 24.h),
                Center(
                  child: GestureDetector(
                    onTap: controller.resend,
                    child: GradientText(
                      controller.isResending.value
                          ? 'auth.sending'.tr
                          : 'auth.sendAnotherCode'.tr,
                      gradient: appTheme.titleGradient,
                      style: CustomTextStyles.authFooter,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: GestureDetector(
                    onTap: controller.leave,
                    child: Text(
                      'auth.differentEmail'.tr,
                      style: CustomTextStyles.authBlurb,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
