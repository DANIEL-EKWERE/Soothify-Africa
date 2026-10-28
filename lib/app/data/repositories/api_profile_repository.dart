import '../../core/network/api_client.dart';
import '../models/profile_stats.dart';
import '../models/user_profile.dart';
import 'profile_repository.dart';

/// The three counters on Profile, from `/api/v1/wellbeing/stats/`.
///
/// Counted server-side from playback and bookings, so a new account reads
/// zero because it has done nothing — not because the number is hardcoded,
/// which is what the local stand-in had to do.
class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._api);

  final ApiClient _api;

  @override
  Future<ProfileStats> getStats() async {
    // The phone's own day. The server runs on UTC, and a week boundary
    // read from there puts Monday in the wrong place for anybody east of
    // Greenwich.
    final now = DateTime.now();
    final day = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final body = await _api.get('/wellbeing/stats/?day=$day');
    return ProfileStats.fromJson(body);
  }

  @override
  Future<UserProfile> me() async =>
      UserProfile.fromJson(await _api.get('/auth/me/'));

  @override
  Future<UserProfile> update({
    String? fullName,
    String? language,
    String? moodFigure,
    String? communityHandle,
  }) async {
    final body = await _api.patch('/auth/me/', body: {
      if (fullName != null) 'full_name': fullName.trim(),
      'language': ?language,
      'mood_figure': ?moodFigure,
      if (communityHandle != null) 'community_handle': communityHandle.trim(),
    });
    return UserProfile.fromJson(body);
  }

  @override
  Future<UserProfile> uploadAvatar(String filePath) async {
    // Multipart and a PATCH: a photo cannot travel as JSON, and the rest of
    // the profile must not be blanked by sending only a picture.
    final body = await _api.upload(
      '/auth/me/',
      method: 'PATCH',
      files: {'avatar': filePath},
    );
    return UserProfile.fromJson(body);
  }
}
