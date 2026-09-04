import '../models/profile_stats.dart';
import 'profile_repository.dart';

/// Stands in for the profile API.
///
/// Returns zeros deliberately rather than invented figures: the design shows
/// every counter at zero, and nothing in the app yet tracks meditation or
/// balance minutes, so any other number would be fiction.
class LocalProfileRepository implements ProfileRepository {
  @override
  Future<ProfileStats> getStats() async => ProfileStats.empty;
}
