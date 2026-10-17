import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/signed_in_user.dart';
import '../../../../data/models/user_role.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/kyc_repository.dart';
import '../../../../data/services/session_service.dart';

/// Which half of the reset the screen is showing.
enum ResetStep { askForEmail, enterCode }

/// Getting back in after forgetting a password.
///
/// No frame was drawn for this, so it follows Log in (`1704:12254`) — the
/// same heading, blurb, filled fields and single action — and lives on one
/// route in two steps, because the code only makes sense immediately after
/// asking for it.
///
/// The server emails a six-digit code rather than a link: a link in an email
/// has to find its way back into the app through a deep link that does not
/// exist yet, and six digits can be typed from the mail app without leaving
/// the screen asking for them.
class ForgotPasswordController extends BaseController {
  ForgotPasswordController(this._auth, this._session, this._kyc);

  final AuthRepository _auth;
  final SessionService _session;
  final KycRepository _kyc;

  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();

  final Rx<ResetStep> step = ResetStep.askForEmail.obs;

  final RxString email = ''.obs;
  final RxString code = ''.obs;
  final RxString password = ''.obs;
  final RxBool obscurePassword = true.obs;

  /// Shown under the field the mistake belongs to, as Log in does.
  final RxnString errorText = RxnString();

  /// What the server said when the code was sent. Deliberately vague about
  /// whether the address has an account, and shown rather than paraphrased.
  final RxnString sentMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Carried from Log in, so nobody types their address twice.
    final given = Get.arguments;
    if (given is String && given.isNotEmpty) {
      emailController.text = given;
      email.value = given;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    codeController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleObscure() => obscurePassword.toggle();

  bool get emailValid =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.value.trim());

  bool get canSend => emailValid;

  /// Six digits, and a password long enough to be worth setting.
  bool get canReset =>
      code.value.trim().length == 6 && password.value.length >= 8;

  /// Ask for the code.
  Future<void> sendCode() async {
    if (isLoading.value) return;
    errorText.value = null;

    if (!emailValid) {
      errorText.value = 'Enter a valid email address.';
      return;
    }

    final sent = await guard(
      () async {
        await _auth.requestPasswordReset(email.value);
        return true;
      },
      showFeedback: false,
      onError: (error) => errorText.value = error.message,
    );
    if (sent != true) return;

    sentMessage.value =
        'If that address has an account, a six-digit code is on its way. '
        'It expires in fifteen minutes.';
    step.value = ResetStep.enterCode;
  }

  /// Use the code and the new password.
  Future<void> reset() async {
    if (isLoading.value) return;
    errorText.value = null;

    if (!canReset) {
      errorText.value = code.value.trim().length != 6
          ? 'The code is six digits.'
          : 'Use at least eight characters.';
      return;
    }

    final user = await guard(
      () => _auth.confirmPasswordReset(
        email: email.value,
        code: code.value,
        password: password.value,
      ),
      showFeedback: false,
      onError: (error) => errorText.value = error.message,
    );
    if (user == null) return;

    await _signIn(user);
  }

  /// Back to the first step, to have another code sent.
  void startAgain() {
    codeController.clear();
    passwordController.clear();
    code.value = '';
    password.value = '';
    errorText.value = null;
    sentMessage.value = null;
    step.value = ResetStep.askForEmail;
  }

  /// A finished reset is a sign-in: they have just proved they hold the
  /// address and chosen a password, so asking them to type it again is
  /// friction for its own sake.
  Future<void> _signIn(SignedInUser user) async {
    await _session.setRole(user.role);
    await PrefUtils().setOnboardingSkipped(false);

    AppFeedback.info('Your password is set. You are signed in.');

    if (user.role == UserRole.practitioner) {
      Get.offAllNamed(AppRoutes.practitionerDashboard);
      return;
    }
    final complete = user.kycComplete || await _kyc.isComplete();
    Get.offAllNamed(complete ? AppRoutes.shell : AppRoutes.kyc);
  }
}
