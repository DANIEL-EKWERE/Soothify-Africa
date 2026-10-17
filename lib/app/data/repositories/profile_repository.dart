import '../models/profile_stats.dart';
import '../models/user_profile.dart';

/// The contract the Profile tab and the account screens code against.
abstract class ProfileRepository {
  Future<ProfileStats> getStats();

  /// Who is signed in, as the server has them.
  Future<UserProfile> me();

  /// Changes what the person chose to change. Anything left null is left
  /// alone — a PATCH, not a replace, so editing a name cannot blank a
  /// language nobody touched.
  Future<UserProfile> update({
    String? fullName,
    String? language,
    String? moodFigure,
    String? communityHandle,
  });

  /// Uploads a new portrait and returns the profile carrying its link.
  Future<UserProfile> uploadAvatar(String filePath);
}
