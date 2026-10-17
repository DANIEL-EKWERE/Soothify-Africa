import 'user_role.dart';

/// The signed-in person's own profile — `GET /api/v1/auth/me/`.
///
/// Distinct from [SignedInUser], which is what a sign-in answers with: this
/// is the account as it stands now, and it is re-read whenever a screen
/// changes part of it.
class UserProfile {
  const UserProfile({
    required this.id,
    this.email = '',
    this.fullName = '',
    this.role = UserRole.user,
    this.language = 'en',
    this.moodFigure = 'female',
    this.communityHandle = '',
    this.avatarUrl = '',
    this.kycComplete = false,
    this.hasPassword = true,
  });

  final String id;
  final String email;
  final String fullName;
  final UserRole role;

  /// 'en' or 'pcm', the same two codes the website uses.
  final String language;

  /// Which figure the mood screens draw — 'female' or 'male'. A display
  /// choice taken from the questionnaire, not a demographic record.
  final String moodFigure;

  final String communityHandle;

  /// A short-lived signed link. Not a path: the file is private, and the
  /// link stops working rather than exposing the bucket.
  final String avatarUrl;

  final bool kycComplete;

  /// Whether this account has a password at all. False for one opened with
  /// Google or Apple, which changes what can be asked for to confirm the
  /// person is who they say — there is no password to type.
  final bool hasPassword;

  /// What the Profile tab prints under the portrait when no name is set.
  String get displayName => fullName.isEmpty ? 'User Profile' : fullName;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: '${json['id'] ?? ''}',
        email: json['email'] as String? ?? '',
        fullName: json['full_name'] as String? ?? '',
        role: UserRole.fromKey(json['role'] as String?) ?? UserRole.user,
        language: json['language'] as String? ?? 'en',
        moodFigure: json['mood_figure'] as String? ?? 'female',
        communityHandle: json['community_handle'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String? ?? '',
        kycComplete: json['kyc_complete'] as bool? ?? false,
        hasPassword: json['has_password'] as bool? ?? true,
      );
}
