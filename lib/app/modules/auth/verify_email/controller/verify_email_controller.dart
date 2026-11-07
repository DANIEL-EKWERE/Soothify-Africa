import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/signed_in_user.dart';
import '../../../../data/models/user_role.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/kyc_repository.dart';
import '../../../../data/services/session_service.dart';

/// Confirming the address a password sign-up was made with.
///
/// No frame was drawn for this, so it follows Reset your password
/// (`ForgotPasswordScreen`, itself built from Log in `1704:12254`) — the
/// same heading, blurb, one filled field and single action.
///
/// A six-digit code rather than a link, for the reason the reset gives: a
/// link in an email has to find its way back into the app through a deep
/// link that does not exist yet.
///
/// The address comes from the session rather than from a field. Somebody
/// reaching this screen has just registered or just signed in, so the
/// server already knows which address it emailed — and letting the app name
/// one would let it ask for somebody else's code.
class VerifyEmailController extends BaseController {
  VerifyEmailController(
    this._auth,
    this._session,
    this._kyc, {
    String? email,
  }) : _given = email;

  final AuthRepository _auth;
  final SessionService _session;
  final KycRepository _kyc;

  /// Injected by the tests. Live, it arrives as [Get.arguments], which has
  /// no setter — hence the seam.
  final String? _given;

  final codeController = TextEditingController();

  final RxString code = ''.obs;

  /// The address the code went to, shown so a mistyped one is noticed here
  /// rather than after five minutes of waiting.
  final RxString email = ''.obs;

  /// Shown under the field, as Log in does.
  final RxnString errorText = RxnString();

  /// What the server said when another code was asked for.
  final RxnString sentMessage = RxnString();

  /// Whether a resend is in flight. Separate from [isLoading], which the
  /// button uses: pressing Resend must not make the main button look busy.
  final RxBool isResending = false.obs;

  @override
  void onInit() {
    super.onInit();
    final given = _given ?? Get.arguments;
    if (given is String && given.isNotEmpty) email.value = given;
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }

  bool get canVerify => code.value.trim().length == 6;

  /// Confirm the address.
  Future<void> verify() async {
    if (isLoading.value) return;
    errorText.value = null;

    if (!canVerify) {
      errorText.value = 'The code is six digits.';
      return;
    }

    final user = await guard(
      () => _auth.verifyEmail(code.value),
      showFeedback: false,
      onError: (error) => errorText.value = error.message,
    );
    if (user == null) return;

    await _goOn(user);
  }

  /// Ask for another code.
  Future<void> resend() async {
    if (isResending.value) return;
    isResending.value = true;
    errorText.value = null;
    sentMessage.value = null;
    try {
      await _auth.resendVerificationCode();
      // The old code stops working the moment a new one is issued, so what
      // is in the field is stale whatever it was.
      codeController.clear();
      code.value = '';
      sentMessage.value = 'A new code is on its way.';
    } on AppException catch (error) {
      errorText.value = error.message;
    } finally {
      isResending.value = false;
    }
  }

  /// Leave without confirming.
  ///
  /// Signs out rather than going back. An account that has not confirmed
  /// its address is not one the app should carry on as, and the half-signed
  /// state is exactly what sends somebody back here on the next launch
  /// wondering why. Back to sign-in, which is where they can try again or
  /// use a different address.
  Future<void> leave() async {
    await _session.signOut();
    await PrefUtils().setEmailUnverified(false);
    Get.offAllNamed(AppRoutes.signin);
  }

  /// A confirmed address means onboarding carries on where it was.
  Future<void> _goOn(SignedInUser user) async {
    await _session.setRole(user.role);
    await PrefUtils().setEmailUnverified(false);

    AppFeedback.info('Your email is confirmed.');

    if (user.role == UserRole.practitioner) {
      Get.offAllNamed(AppRoutes.practitionerDashboard);
      return;
    }
    // A studio has its own portal, and no questionnaire to answer.
    if (user.role == UserRole.partner) {
      Get.offAllNamed(AppRoutes.partnerPortal);
      return;
    }
    final complete = user.kycComplete || await _kyc.isComplete();
    Get.offAllNamed(complete ? AppRoutes.shell : AppRoutes.kyc);
  }
}
