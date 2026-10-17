import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/data/models/user_role.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';
import 'package:soothifyafrica/app/data/repositories/local_kyc_repository.dart';
import 'package:soothifyafrica/app/data/services/session_service.dart';
import 'package:soothifyafrica/app/modules/auth/signin/controller/signin_controller.dart';
import 'package:soothifyafrica/app/modules/auth/signup/controller/signup_controller.dart';
import 'package:soothifyafrica/app/core/errors/app_exception.dart';

import 'helpers.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(Get.reset);

  group('PasswordRule', () {
    test('each rule checks only its own condition', () {
      expect(PasswordRule.length.isMet('abcdefgh'), isTrue);
      expect(PasswordRule.length.isMet('abc'), isFalse);
      expect(PasswordRule.uppercase.isMet('abcD'), isTrue);
      expect(PasswordRule.uppercase.isMet('abcd'), isFalse);
      expect(PasswordRule.lowercase.isMet('ABCd'), isTrue);
      expect(PasswordRule.lowercase.isMet('ABCD'), isFalse);
    });
  });

  group('SignupController', () {
    late SignupController c;

    setUp(() async {
      c = SignupController(
        await SessionService().init(),
        LocalKycRepository(),
        StubAuthRepository(),
      );
    });

    test('Create Account stays blocked until every field is valid', () {
      expect(c.canSubmit, isFalse);

      c.fullname.value = 'Chidera Okafor';
      expect(c.canSubmit, isFalse, reason: 'email still missing');

      c.email.value = 'chidera@example.com';
      expect(c.canSubmit, isFalse, reason: 'password still missing');

      c.password.value = 'Chidera50';
      expect(c.canSubmit, isFalse, reason: 'confirmation still missing');

      c.confirm.value = 'Chidera50';
      expect(c.canSubmit, isTrue);
    });

    test('a mismatched confirmation blocks submission', () {
      c
        ..fullname.value = 'Chidera Okafor'
        ..email.value = 'chidera@example.com'
        ..password.value = 'Chidera50'
        ..confirm.value = 'Chidera51';

      expect(c.confirmMatches, isFalse);
      expect(c.canSubmit, isFalse);
    });

    test('a password missing a rule blocks submission', () {
      c
        ..fullname.value = 'Chidera Okafor'
        ..email.value = 'chidera@example.com'
        // No uppercase.
        ..password.value = 'chidera50'
        ..confirm.value = 'chidera50';

      expect(c.ruleMet(PasswordRule.uppercase), isFalse);
      expect(c.canSubmit, isFalse);
    });

    test('a malformed email blocks submission', () {
      c
        ..fullname.value = 'Chidera Okafor'
        ..email.value = 'chidera@'
        ..password.value = 'Chidera50'
        ..confirm.value = 'Chidera50';

      expect(c.emailValid, isFalse);
      expect(c.canSubmit, isFalse);
    });
  });

  group('SigninController', () {
    late SigninController c;
    late SessionService session;

    setUp(() async {
      session = await SessionService().init();
      c = SigninController(session, LocalKycRepository(), StubAuthRepository());
    });

    test('Proceed stays blocked without both fields', () {
      expect(c.canSubmit, isFalse);
      c.email.value = 'chidera@example.com';
      expect(c.canSubmit, isFalse);
      c.password.value = 'secret1';
      expect(c.canSubmit, isTrue);
    });

    test('a bad email reports inline and starts no session', () async {
      c
        ..email.value = 'nope'
        ..password.value = 'secret1';

      await c.submit();

      expect(c.errorText.value, isNotNull);
      expect(session.isSignedIn, isFalse);
    });

    test('an empty password is caught before the server is asked', () async {
      c
        ..email.value = 'chidera@example.com'
        ..password.value = '';

      await c.submit();

      expect(c.errorText.value, contains('Enter your password'));
      expect(session.isSignedIn, isFalse);
    });

    test('a refused credential shows the server\'s own wording', () async {
      // Which password is wrong, and whether the address even has an
      // account, are the server's to judge -- and it deliberately does not
      // say which of the two it was.
      final refused = SigninController(
        session,
        LocalKycRepository(),
        StubAuthRepository(
          error: const ValidationException(
            'You entered an incorrect password. Please try again',
          ),
        ),
      );
      refused
        ..email.value = 'chidera@example.com'
        ..password.value = 'abc';

      await refused.submit();

      expect(refused.errorText.value, contains('incorrect password'));
      expect(session.isSignedIn, isFalse);
    });

    testWidgets('a good credential starts the session and goes in',
        (tester) async {
      // A widget test, because a successful sign-in leaves for the app and
      // navigation needs a tree to leave through.
      Get.testMode = true;
      await pumpScreen(
        tester,
        const SizedBox.shrink(),
        pages: [
          GetPage(name: AppRoutes.shell, page: () => const Text('home')),
          GetPage(name: AppRoutes.kyc, page: () => const Text('questions')),
        ],
      );

      c
        ..email.value = 'chidera@example.com'
        ..password.value = 'Soothify2026';
      unawaited(c.submit());
      await settleLoads(tester);

      expect(c.errorText.value, isNull);
      expect(session.isSignedIn, isTrue);
      // The questionnaire, because this account has not answered it.
      expect(find.text('questions'), findsOneWidget);
    });
  });

  group('SessionService', () {
    test('signing in and out round-trips the role', () async {
      final s = await SessionService().init();
      expect(s.isSignedIn, isFalse);

      await s.setRole(UserRole.user);
      expect((await SessionService().init()).role.value, UserRole.user);

      await s.signOut();
      expect(s.isSignedIn, isFalse);
    });
  });
}
