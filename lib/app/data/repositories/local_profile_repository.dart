import '../models/profile_stats.dart';
import '../models/user_profile.dart';
import 'profile_repository.dart';

/// Stands in for the profile API.
///
/// Returns zeros deliberately rather than invented figures: the design shows
/// every counter at zero, and nothing in the app yet tracks meditation or
/// balance minutes, so any other number would be fiction.
class LocalProfileRepository implements ProfileRepository {
  static const _latency = Duration(milliseconds: 200);

  @override
  Future<ProfileStats> getStats() async => ProfileStats.empty;

  /// Held in memory for the length of the run. Nothing on the device is a
  /// profile: the account lives on the server, and pretending otherwise
  /// would show a stale name after a real sign-in.
  UserProfile _profile = const UserProfile(id: 'local');

  @override
  Future<UserProfile> me() async {
    await Future<void>.delayed(_latency);
    return _profile;
  }

  @override
  Future<UserProfile> update({
    String? fullName,
    String? language,
    String? moodFigure,
    String? communityHandle,
  }) async {
    await Future<void>.delayed(_latency);
    _profile = UserProfile(
      id: _profile.id,
      email: _profile.email,
      fullName: fullName ?? _profile.fullName,
      role: _profile.role,
      language: language ?? _profile.language,
      moodFigure: moodFigure ?? _profile.moodFigure,
      communityHandle: communityHandle ?? _profile.communityHandle,
      avatarUrl: _profile.avatarUrl,
      kycComplete: _profile.kycComplete,
    );
    return _profile;
  }

  @override
  Future<UserProfile> uploadAvatar(String filePath) async {
    await Future<void>.delayed(_latency);
    // The file stays where it is; nothing is uploaded, and the screen shows
    // the local path so the choice is at least visible.
    _profile = UserProfile(
      id: _profile.id,
      email: _profile.email,
      fullName: _profile.fullName,
      role: _profile.role,
      language: _profile.language,
      moodFigure: _profile.moodFigure,
      communityHandle: _profile.communityHandle,
      avatarUrl: filePath,
      kycComplete: _profile.kycComplete,
    );
    return _profile;
  }
}
