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
  });

  final UserRole role;
  final String fullName;
  final String email;

  /// Whether the onboarding questionnaire has been finished. False sends
  /// them to it; true sends them into the app.
  final bool kycComplete;

  factory SignedInUser.fromProfile(Map<String, dynamic>? profile) {
    final row = profile ?? const <String, dynamic>{};
    return SignedInUser(
      role: UserRole.fromKey(row['role'] as String?) ?? UserRole.user,
      fullName: row['full_name'] as String? ?? '',
      email: row['email'] as String? ?? '',
      kycComplete: row['kyc_complete'] as bool? ?? false,
    );
  }
}
