import 'user_role.dart';

/// Who just signed in, as the server describes them.
///
/// Registering, signing in, a social sign-in and finishing a password reset
/// all answer with the same thing — tokens and a profile — so they all come
/// back as this. [kycComplete] travels with it because the screen that
/// follows depends on it, and a second round trip to ask would be a spinner
/// the user sits through for no reason.
class SignedInUser {
  const SignedInUser({
    required this.role,
    this.fullName = '',
    this.email = '',
    this.kycComplete = false,
    this.emailVerified = true,
  });

  final UserRole role;
  final String fullName;
  final String email;

  /// Whether the onboarding questionnaire has been finished. False sends
  /// them to it; true sends them into the app.
  final bool kycComplete;

  /// Whether they have proved they hold [email].
  ///
  /// Travels with the sign-in for the same reason as [kycComplete]: the
  /// screen that follows depends on it.
  ///
  /// Defaults to true, not false. A server that does not send the field is
  /// one from before verification existed, and reading its silence as
  /// "unverified" would park every user of an older build on a screen
  /// asking for a code that nothing will send.
  final bool emailVerified;

  factory SignedInUser.fromProfile(Map<String, dynamic>? profile) {
    final row = profile ?? const <String, dynamic>{};
    return SignedInUser(
      role: UserRole.fromKey(row['role'] as String?) ?? UserRole.user,
      fullName: row['full_name'] as String? ?? '',
      email: row['email'] as String? ?? '',
      kycComplete: row['kyc_complete'] as bool? ?? false,
      emailVerified: row['email_verified'] as bool? ?? true,
    );
  }
}
