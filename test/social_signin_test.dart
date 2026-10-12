import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/errors/app_exception.dart';
import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/user_role.dart';
import 'package:soothifyafrica/app/data/repositories/local_kyc_repository.dart';
import 'package:soothifyafrica/app/data/services/session_service.dart';
import 'package:soothifyafrica/app/modules/auth/signin/controller/signin_controller.dart';
import 'package:soothifyafrica/app/modules/auth/signup/controller/signup_controller.dart';

import 'helpers.dart';

/// The two social buttons on both auth screens. The provider SDKs cannot run
/// here, so [StubAuthRepository] stands in and what is pinned is what the
/// controllers do with each answer.
void main() {
  setUp(() async {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
    await PrefUtils().init();
    Get.testMode = true;
  });
  tearDown(Get.reset);

  Future<SigninController> signin(StubAuthRepository auth) async {
    // Registered, not just constructed: the controllers read it back out of
    // GetX after signing in.
    final session = Get.put(await SessionService().init());
    return SigninController(session, LocalKycRepository(), auth);
  }

  test('Google sign-in establishes the session', () async {
    final auth = StubAuthRepository(role: UserRole.user);
    final c = await signin(auth);

    await c.continueWithGoogle();

    expect(auth.googleCalls, 1);
    expect(Get.find<SessionService>().isSignedIn, isTrue);
    // Where it lands afterwards is the same KYC-or-shell decision the
    // password path makes, and flow_test already drives that against a real
    // navigator. There is none here, so Get.currentRoute stays empty.
  });

  test('the role the server returns is the role taken', () async {
    final c = await signin(StubAuthRepository(role: UserRole.practitioner));
    await c.continueWithGoogle();
    expect(Get.find<SessionService>().role.value, UserRole.practitioner);
  });

  /// Dismissing Google's account sheet is a decision, not a failure. It used
  /// to be impossible to tell the two apart.
  test('backing out of the provider sheet signs nobody in', () async {
    final auth = StubAuthRepository(role: null);
    final c = await signin(auth);

    await c.continueWithGoogle();

    expect(auth.googleCalls, 1);
    expect(Get.find<SessionService>().isSignedIn, isFalse);
  });

  test('a refused token leaves the user signed out', () async {
    final c = await signin(
      StubAuthRepository(error: const UnauthorizedException()),
    );

    // guard() renders the failure; it must not escape as an unhandled error.
    await c.continueWithGoogle();

    expect(Get.find<SessionService>().isSignedIn, isFalse);
  });

  test('Apple goes through the same path as Google', () async {
    final auth = StubAuthRepository(role: UserRole.user);
    final c = await signin(auth);

    await c.continueWithApple();

    expect(auth.appleCalls, 1);
    expect(auth.googleCalls, 0);
    expect(Get.find<SessionService>().isSignedIn, isTrue);
  });

  /// Signing up socially supersedes a skipped onboarding — the same rule the
  /// password path follows, or the next launch walks past the KYC that
  /// taking an account just asked for.
  test('taking an account clears a skipped onboarding', () async {
    await PrefUtils().setOnboardingSkipped(true);
    final c = await signin(StubAuthRepository(role: UserRole.user));

    await c.continueWithGoogle();

    expect(PrefUtils().onboardingSkipped(), isFalse);
  });

  test('the sign-up screen offers the same two buttons', () async {
    final auth = StubAuthRepository(role: UserRole.user);
    final session = Get.put(await SessionService().init());
    final c = SignupController(session, LocalKycRepository(), auth);

    await c.continueWithApple();

    expect(auth.appleCalls, 1);
    expect(Get.find<SessionService>().isSignedIn, isTrue);
  });
}
