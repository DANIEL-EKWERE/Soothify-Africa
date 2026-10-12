import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/user_role.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/kyc_repository.dart';
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
  SignupController(this._session, this._kyc, this._auth);

  final SessionService _session;
  final KycRepository _kyc;
  final AuthRepository _auth;

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
    if (ok != true) return;

    // Taking an account supersedes a skipped onboarding. Clearing the flag
    // matters beyond this navigation: without it, quitting part-way through
    // the questionnaire would leave `resolveStartRoute` still treating it as
    // skipped, and the next launch would walk straight past the KYC that
    // registering had just asked for.
    await PrefUtils().setOnboardingSkipped(false);

    // Guests reach sign-up from Profile having already answered the
    // questionnaire during onboarding, so sending everyone to KYC would make
    // them repeat it. Signing in has always checked; signing up now does too.
    final complete = await _kyc.isComplete();
    Get.offAllNamed(complete ? AppRoutes.shell : AppRoutes.kyc);
  }

  void goToSignIn() => Get.offAllNamed(AppRoutes.signin);

  /// The two social buttons the frames draw.
  ///
  /// Each runs the provider's own flow; a verified identity token goes to
  /// the Django API, which answers with our session. A null result means the
  /// user dismissed the provider's sheet — that is a decision, not an error,
  /// so nothing is said about it.
  Future<void> continueWithGoogle() => _social(_auth.signInWithGoogle);

  Future<void> continueWithApple() => _social(_auth.signInWithApple);

  Future<void> _social(Future<UserRole?> Function() signIn) async {
    if (isLoading.value) return;

    final role = await guard(signIn);
    if (role == null) return;

    await _session.setRole(role);
    // Taking an account supersedes a skipped onboarding — same reason as
    // submit() above.
    await PrefUtils().setOnboardingSkipped(false);

    final complete = await _kyc.isComplete();
    Get.offAllNamed(complete ? AppRoutes.shell : AppRoutes.kyc);
  }
}
