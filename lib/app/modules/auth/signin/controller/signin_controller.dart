import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/user_role.dart';
import '../../../../data/repositories/kyc_repository.dart';
import '../../../../data/services/session_service.dart';

class SigninController extends BaseController {
  SigninController(this._session, this._kyc);

  final SessionService _session;
  final KycRepository _kyc;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxBool obscurePassword = true.obs;

  /// Populates the inline message the design shows beneath the password
  /// field, rather than a snackbar.
  final RxnString errorText = RxnString();

  bool get emailValid =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.value.trim());

  bool get canSubmit => emailValid && password.value.isNotEmpty;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleObscure() => obscurePassword.toggle();

  /// No backend yet: this validates and establishes a local session. The
  /// design's error state is what a rejected credential will populate once
  /// the Django call replaces this body.
  Future<void> submit() async {
    if (isLoading.value) return;
    errorText.value = null;

    if (!emailValid) {
      errorText.value = 'Enter a valid email address.';
      return;
    }
    if (password.value.length < 6) {
      errorText.value =
          'You entered an incorrect password. Please try again';
      return;
    }

    final ok = await guard(() async {
      await _session.setRole(UserRole.user);
      return true;
    });
    if (ok != true) return;

    final complete = await _kyc.isComplete();
    Get.offAllNamed(complete ? AppRoutes.shell : AppRoutes.kyc);
  }

  void goToSignUp() => Get.offAllNamed(AppRoutes.signup);

  void forgotPassword() =>
      AppFeedback.info('Password recovery arrives with the backend.');

  void continueWithGoogle() =>
      AppFeedback.info('Google sign-in arrives with the backend.');
}
