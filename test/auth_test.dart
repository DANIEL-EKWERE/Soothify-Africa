import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/data/models/user_role.dart';
import 'package:soothifyafrica/app/data/repositories/local_kyc_repository.dart';
import 'package:soothifyafrica/app/data/services/session_service.dart';
import 'package:soothifyafrica/app/modules/auth/signin/controller/signin_controller.dart';
import 'package:soothifyafrica/app/modules/auth/signup/controller/signup_controller.dart';

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
      c = SignupController(await SessionService().init(), LocalKycRepository());
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
      c = SigninController(session, LocalKycRepository());
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

    test('a short password reports the design\'s message', () async {
      c
        ..email.value = 'chidera@example.com'
        ..password.value = 'abc';

      await c.submit();

      expect(c.errorText.value, contains('incorrect password'));
      expect(session.isSignedIn, isFalse);
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
