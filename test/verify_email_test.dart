import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/errors/app_exception.dart';
import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/signed_in_user.dart';
import 'package:soothifyafrica/app/data/models/user_role.dart';
import 'package:soothifyafrica/app/data/repositories/local_kyc_repository.dart';
import 'package:soothifyafrica/app/data/services/session_service.dart';
import 'package:soothifyafrica/app/modules/auth/signin/controller/signin_controller.dart';
import 'package:soothifyafrica/app/modules/auth/signup/controller/signup_controller.dart';
import 'package:soothifyafrica/app/modules/auth/splash/start_route.dart';
import 'package:soothifyafrica/app/modules/auth/verify_email/controller/verify_email_controller.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';

import 'helpers.dart';

/// Lets the confirmation snackbar finish.
///
/// `_goOn` shows one for three seconds and then animates it away. Both the
/// timer and the dismiss animation outlive the tree the navigation left, so
/// a test that stops at the assertion fails on a pending ticker rather than
/// on anything the controller did.
Future<void> drainFeedback(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

/// Confirming the address a password sign-up was made with.
///
/// Tested as a chain, not link by link: the thing that matters is that
/// registering lands on the code screen and that typing the code leaves it.
/// Every piece can be right on its own while the chain is broken.
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefUtils().init();
  });
  tearDown(Get.reset);

  /// The routes the flow leaves through. Without them GetX throws rather
  /// than navigating.
  List<GetPage<dynamic>> routes() => [
        GetPage(name: AppRoutes.shell, page: () => const Text('home')),
        GetPage(name: AppRoutes.kyc, page: () => const Text('questions')),
        GetPage(name: AppRoutes.signin, page: () => const Text('log in')),
        GetPage(
          name: AppRoutes.partnerPortal,
          page: () => const Text('portal'),
        ),
        GetPage(
          name: AppRoutes.practitionerDashboard,
          page: () => const Text('practitioner'),
        ),
        GetPage(
          name: AppRoutes.verifyEmail,
          page: () => const Text('enter the code'),
        ),
      ];

  group('SignedInUser', () {
    test('reads the flag the server sends', () {
      expect(
        SignedInUser.fromProfile({'email_verified': false}).emailVerified,
        isFalse,
      );
      expect(
        SignedInUser.fromProfile({'email_verified': true}).emailVerified,
        isTrue,
      );
    });

    test('a server that says nothing is treated as verified', () {
      // An older build must not park every user on a screen asking for a
      // code that nothing will send.
      expect(SignedInUser.fromProfile({}).emailVerified, isTrue);
      expect(SignedInUser.fromProfile(null).emailVerified, isTrue);
    });
  });

  group('after signing up', () {
    testWidgets('an unconfirmed address goes to the code screen',
        (tester) async {
      Get.testMode = true;
      await pumpScreen(tester, const SizedBox.shrink(), pages: routes());

      final c = SignupController(
        await SessionService().init(),
        LocalKycRepository(),
        StubAuthRepository(emailVerified: false),
      );
      c
        ..fullname.value = 'Chidera Okafor'
        ..email.value = 'chidera@example.com'
        ..password.value = 'Chidera50'
        ..confirm.value = 'Chidera50';

      unawaited(c.submit());
      await settleLoads(tester);

      expect(find.text('enter the code'), findsOneWidget);
      expect(find.text('questions'), findsNothing);
      // And it survives a relaunch.
      expect(PrefUtils().emailUnverified(), isTrue);
    });

    testWidgets('a confirmed address carries straight on', (tester) async {
      Get.testMode = true;
      await pumpScreen(tester, const SizedBox.shrink(), pages: routes());

      final c = SignupController(
        await SessionService().init(),
        LocalKycRepository(),
        StubAuthRepository(emailVerified: true),
      );
      c
        ..fullname.value = 'Chidera Okafor'
        ..email.value = 'chidera@example.com'
        ..password.value = 'Chidera50'
        ..confirm.value = 'Chidera50';

      unawaited(c.submit());
      await settleLoads(tester);

      expect(find.text('questions'), findsOneWidget);
      expect(PrefUtils().emailUnverified(), isFalse);
    });

    testWidgets('a practitioner is asked too', (tester) async {
      // A practitioner and a studio own an address the same way a member
      // does, so the check comes before the role branches.
      Get.testMode = true;
      await pumpScreen(tester, const SizedBox.shrink(), pages: routes());

      final c = SignupController(
        await SessionService().init(),
        LocalKycRepository(),
        StubAuthRepository(
          role: UserRole.practitioner,
          emailVerified: false,
        ),
      );
      c
        ..fullname.value = 'Ada Obi'
        ..email.value = 'ada@example.com'
        ..password.value = 'Chidera50'
        ..confirm.value = 'Chidera50';

      unawaited(c.submit());
      await settleLoads(tester);

      expect(find.text('enter the code'), findsOneWidget);
      expect(find.text('practitioner'), findsNothing);
    });
  });

  group('after signing in', () {
    testWidgets('an account that never confirmed is sent back', (tester) async {
      // Somebody who closed the app before typing the code.
      Get.testMode = true;
      await pumpScreen(tester, const SizedBox.shrink(), pages: routes());

      final c = SigninController(
        await SessionService().init(),
        LocalKycRepository(),
        StubAuthRepository(emailVerified: false, kycComplete: true),
      );
      c
        ..email.value = 'chidera@example.com'
        ..password.value = 'Soothify2026';

      unawaited(c.submit());
      await settleLoads(tester);

      expect(find.text('enter the code'), findsOneWidget);
      expect(find.text('home'), findsNothing);
    });
  });

  group('on relaunch', () {
    test('an unconfirmed account goes to the code screen', () async {
      await PrefUtils().setIntroSeen(true);
      await PrefUtils().setEmailUnverified(true);
      await PrefUtils().setTokens(access: 'a-token', refresh: 'r');
      final session = await SessionService().init();
      await session.setRole(UserRole.user);

      expect(
        await resolveStartRoute(session: session, kyc: LocalKycRepository()),
        AppRoutes.verifyEmail,
      );
    });

    test('a guest is left alone', () async {
      // A role is chosen during onboarding, before anybody registers. A
      // guest has no address to confirm, and no token to confirm it with.
      await PrefUtils().setIntroSeen(true);
      await PrefUtils().setEmailUnverified(true);
      final session = await SessionService().init();
      await session.setRole(UserRole.user);

      expect(
        await resolveStartRoute(session: session, kyc: LocalKycRepository()),
        isNot(AppRoutes.verifyEmail),
      );
    });

    test('an install from before verification is unaffected', () async {
      await PrefUtils().setIntroSeen(true);
      await PrefUtils().setTokens(access: 'a-token', refresh: 'r');
      final session = await SessionService().init();
      await session.setRole(UserRole.user);

      expect(PrefUtils().emailUnverified(), isFalse);
      expect(
        await resolveStartRoute(session: session, kyc: LocalKycRepository()),
        isNot(AppRoutes.verifyEmail),
      );
    });

    test('a confirmed account is sent on as before', () async {
      await PrefUtils().setIntroSeen(true);
      await PrefUtils().setEmailUnverified(false);
      await PrefUtils().setTokens(access: 'a-token', refresh: 'r');
      final session = await SessionService().init();
      await session.setRole(UserRole.partner);

      expect(
        await resolveStartRoute(session: session, kyc: LocalKycRepository()),
        AppRoutes.partnerPortal,
      );
    });
  });

  group('VerifyEmailController', () {
    late StubAuthRepository auth;
    late VerifyEmailController c;

    Future<void> build({StubAuthRepository? repo}) async {
      auth = repo ?? StubAuthRepository();
      c = VerifyEmailController(
        auth,
        await SessionService().init(),
        LocalKycRepository(),
        email: 'chidera@example.com',
      );
      c.onInit();
    }

    test('the address is shown, so a typo is noticed here', () async {
      await build();
      expect(c.email.value, 'chidera@example.com');
    });

    test('Confirm stays blocked until six digits are typed', () async {
      await build();
      expect(c.canVerify, isFalse);
      c.code.value = '123';
      expect(c.canVerify, isFalse);
      c.code.value = '123456';
      expect(c.canVerify, isTrue);
    });

    test('a short code is refused without calling the server', () async {
      await build();
      c.code.value = '123';
      await c.verify();
      expect(auth.verifyCalls, 0);
      expect(c.errorText.value, contains('six digits'));
    });

    test("the server's own message is what is shown", () async {
      await build(
        repo: StubAuthRepository(
          verifyError: const ValidationException(
            'That code is wrong or has expired. Ask for a new one.',
          ),
        ),
      );
      c.code.value = '000000';
      await c.verify();

      expect(auth.verifyCalls, 1);
      expect(c.errorText.value, contains('wrong or has expired'));
      // Still owed, so a relaunch comes back here.
      expect(PrefUtils().emailUnverified(), isFalse,
          reason: 'nothing set it yet in this test');
    });

    testWidgets('the right code clears the flag and goes on', (tester) async {
      Get.testMode = true;
      await pumpScreen(tester, const SizedBox.shrink(), pages: routes());
      await PrefUtils().setEmailUnverified(true);

      await build();
      c.code.value = '123456';
      unawaited(c.verify());
      await settleLoads(tester);

      expect(auth.lastCode, '123456');
      expect(PrefUtils().emailUnverified(), isFalse);
      expect(find.text('questions'), findsOneWidget);

      await drainFeedback(tester);
    });

    testWidgets('a studio lands in its portal, not the questionnaire',
        (tester) async {
      Get.testMode = true;
      await pumpScreen(tester, const SizedBox.shrink(), pages: routes());

      await build(repo: StubAuthRepository(role: UserRole.partner));
      c.code.value = '123456';
      unawaited(c.verify());
      await settleLoads(tester);

      expect(find.text('portal'), findsOneWidget);
      await drainFeedback(tester);
    });

    test('asking for another code clears the stale one', () async {
      await build();
      c.codeController.text = '111111';
      c.code.value = '111111';

      await c.resend();

      expect(auth.resendCalls, 1);
      // The old code stops working the moment a new one is issued, so what
      // is in the field is stale whatever it was.
      expect(c.code.value, isEmpty);
      expect(c.codeController.text, isEmpty);
      expect(c.sentMessage.value, contains('on its way'));
    });

    test('a resend that fails says so and is not left spinning', () async {
      await build(
        repo: StubAuthRepository(
          error: const UnknownException('Sending a code needs the server.'),
        ),
      );
      await c.resend();

      expect(c.errorText.value, contains('needs the server'));
      expect(c.isResending.value, isFalse);
    });

    testWidgets('leaving signs out rather than going back', (tester) async {
      // Going back would leave the app signed in as an account that has not
      // confirmed its address.
      Get.testMode = true;
      await pumpScreen(tester, const SizedBox.shrink(), pages: routes());
      await PrefUtils().setEmailUnverified(true);

      await build();
      unawaited(c.leave());
      await settleLoads(tester);

      expect(find.text('log in'), findsOneWidget);
      expect(PrefUtils().emailUnverified(), isFalse);
    });
  });
}
