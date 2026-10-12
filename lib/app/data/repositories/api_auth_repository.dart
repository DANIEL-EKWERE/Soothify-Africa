import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/pref_utils.dart';
import '../models/user_role.dart';
import 'auth_repository.dart';

/// Google and Apple sign-in against the Django API.
///
/// The phone runs the provider's flow, the provider returns a signed identity
/// token, and the server verifies it before issuing our own session. The app
/// never sends an email it merely believes — a token is the only thing the
/// server trusts, because a token is the only thing it can check.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api, {GoogleSignIn? google})
    : _google = google ?? GoogleSignIn(scopes: const ['email', 'profile']);

  final ApiClient _api;
  final GoogleSignIn _google;

  static const _googlePath = '/auth/google/';
  static const _applePath = '/auth/apple/';

  @override
  Future<UserRole?> signInWithGoogle() async {
    final GoogleSignInAccount? account;
    try {
      // Signs the previous account out first. Without it the SDK silently
      // reuses the last one, so a user who wanted to switch accounts cannot.
      await _google.signOut();
      account = await _google.signIn();
    } on PlatformException catch (e) {
      Log.e('Google sign-in failed', error: e);
      // 10 is DEVELOPER_ERROR: the signing certificate's SHA-1 is not
      // registered against this package in the Firebase console. It is the
      // single most common cause and worth naming rather than hiding behind
      // "something went wrong".
      throw e.code == '10'
          ? const UnknownException(
              'Google sign-in is not set up for this build yet.',
            )
          : const UnknownException('Google sign-in did not complete.');
    }

    // The user dismissed the account sheet.
    if (account == null) return null;

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const UnknownException('Google did not return a sign-in token.');
    }

    return _establish(_googlePath, {'id_token': idToken});
  }

  @override
  Future<UserRole?> signInWithApple() async {
    if (!kIsWeb && !Platform.isIOS && !Platform.isMacOS) {
      // Apple's flow is available on Android through a web redirect, but it
      // needs a Services ID and a return URL that do not exist yet. Saying
      // so beats a half-configured sheet failing in front of the user.
      throw const UnknownException(
        'Apple sign-in is available on iOS devices.',
      );
    }

    final AuthorizationCredentialAppleID credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      Log.e('Apple sign-in failed', error: e);
      throw const UnknownException('Apple sign-in did not complete.');
    }

    final token = credential.identityToken;
    if (token == null || token.isEmpty) {
      throw const UnknownException('Apple did not return a sign-in token.');
    }

    // Apple sends the name on the first authorisation only, and never again.
    // It goes up with this request because there will be no second chance.
    final name = [credential.givenName, credential.familyName]
        .whereType<String>()
        .where((part) => part.isNotEmpty)
        .join(' ');

    return _establish(_applePath, {
      'identity_token': token,
      if (name.isNotEmpty) 'full_name': name,
    });
  }

  /// Exchanges a verified provider token for our own session.
  Future<UserRole> _establish(String path, Map<String, dynamic> body) async {
    final response = await _api.post(path, body: body);

    final tokens = response['tokens'];
    if (tokens is! Map || tokens['access'] is! String) {
      throw const ServerException('Sign-in did not return a session.');
    }
    await PrefUtils().setTokens(
      access: tokens['access'] as String,
      refresh: (tokens['refresh'] as String?) ?? '',
    );

    final profile = response['profile'];
    final role = profile is Map ? profile['role'] as String? : null;
    return UserRole.fromKey(role) ?? UserRole.user;
  }
}
