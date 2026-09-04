import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/user_role.dart';
import '../../../../data/services/session_service.dart';

/// The password rules the design surfaces as chips beneath the field.
enum PasswordRule {
  length('8 characters'),
  uppercase('Uppercase letter'),
  lowercase('Lowercase letter');

  const PasswordRule(this.label);

  final String label;

  bool isMet(String value) => switch (this) {
        PasswordRule.length => value.length >= 8,
        PasswordRule.uppercase => value.contains(RegExp(r'[A-Z]')),
        PasswordRule.lowercase => value.contains(RegExp(r'[a-z]')),
      };
}

class SignupController extends BaseController {
  SignupController(this._session);

  final SessionService _session;

  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  final RxString password = ''.obs;
  final RxString confirm = ''.obs;
  final RxString email = ''.obs;
  final RxString fullname = ''.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirm = true.obs;

  bool ruleMet(PasswordRule rule) => rule.isMet(password.value);

  bool get emailValid =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.value.trim());

  bool get passwordValid => PasswordRule.values.every(ruleMet);

  bool get confirmMatches =>
      confirm.value.isNotEmpty && confirm.value == password.value;

  bool get canSubmit =>
      fullname.value.trim().isNotEmpty &&
      emailValid &&
      passwordValid &&
      confirmMatches;

  @override
  void onClose() {
    fullnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.onClose();
  }

  void toggleObscurePassword() => obscurePassword.toggle();
  void toggleObscureConfirm() => obscureConfirm.toggle();

  /// No backend yet: this validates and establishes a local session. Replace
  /// the body with the Django call when the API exists — nothing outside this
  /// method needs to change.
  Future<void> submit() async {
    if (isLoading.value) return;

    if (!canSubmit) {
      AppFeedback.error(const ValidationException(
        'Please complete every field before continuing.',
      ));
      return;
    }

    final ok = await guard(() async {
      await _session.setRole(UserRole.user);
      return true;
    });
    if (ok == true) Get.offAllNamed(AppRoutes.kyc);
  }

  void goToSignIn() => Get.offAllNamed(AppRoutes.signin);

  void continueWithGoogle() => AppFeedback.info(
        'Google sign-in arrives with the backend.',
      );
}
