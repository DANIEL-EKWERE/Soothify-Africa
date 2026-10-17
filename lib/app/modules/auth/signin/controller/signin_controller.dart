import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/signed_in_user.dart';
import '../../../../data/models/user_role.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/kyc_repository.dart';
import '../../../../data/services/session_service.dart';

class SigninController extends BaseController {
  SigninController(this._session, this._kyc, this._auth);

  final SessionService _session;
  final KycRepository _kyc;
  final AuthRepository _auth;

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

  /// Signs in against the server.
  ///
  /// The two obvious mistakes are caught here so the form can answer
  /// without a round trip; everything else is the server's to judge, and
  /// its wording is what the field shows. A wrong password is deliberately
  /// not distinguished from an unknown address: saying which would tell a
  /// stranger who has an account here.
  Future<void> submit() async {
    if (isLoading.value) return;
    errorText.value = null;

    if (!emailValid) {
      errorText.value = 'Enter a valid email address.';
      return;
    }
    if (password.value.isEmpty) {
      errorText.value = 'Enter your password.';
      return;
    }

    final user = await guard(
      () => _auth.signIn(email: email.value, password: password.value),
      // Shown under the field, as the design draws it, rather than over the
      // screen in a snackbar.
      showFeedback: false,
      onError: (error) => errorText.value = error.message,
    );
    if (user == null) return;

    await _establish(user);
  }

  void goToSignUp() => Get.offAllNamed(AppRoutes.signup);

  /// Carries whatever they have typed into the reset screen, so they do not
  /// type their address twice.
  void forgotPassword() => Get.toNamed(
        AppRoutes.forgotPassword,
        arguments: email.value.trim(),
      );

  /// The two social buttons the frames draw.
  ///
  /// Each runs the provider's own flow; a verified identity token goes to
  /// the Django API, which answers with our session. A null result means the
  /// user dismissed the provider's sheet — that is a decision, not an error,
  /// so nothing is said about it.
  Future<void> continueWithGoogle() => _social(_auth.signInWithGoogle);

  Future<void> continueWithApple() => _social(_auth.signInWithApple);

  Future<void> _social(Future<SignedInUser?> Function() signIn) async {
    if (isLoading.value) return;
    errorText.value = null;

    final user = await guard(signIn);
    if (user == null) return;

    await _establish(user);
  }

  /// What follows a successful sign-in, however it was done.
  ///
  /// Taking an account supersedes a skipped onboarding. Clearing that flag
  /// matters beyond this navigation: without it, quitting part-way through
  /// the questionnaire would leave `resolveStartRoute` still treating it as
  /// skipped, and the next launch would walk straight past the KYC that
  /// signing in had just asked for.
  Future<void> _establish(SignedInUser user) async {
    await _session.setRole(user.role);
    await PrefUtils().setOnboardingSkipped(false);

    // The server's answer, not a second call: it told us with the session
    // whether the questionnaire is done. The local repository is still
    // asked when the server said nothing, which is the offline build.
    final complete = user.kycComplete || await _kyc.isComplete();

    if (user.role == UserRole.practitioner) {
      Get.offAllNamed(AppRoutes.practitionerDashboard);
      return;
    }
    Get.offAllNamed(complete ? AppRoutes.shell : AppRoutes.kyc);
  }
}
