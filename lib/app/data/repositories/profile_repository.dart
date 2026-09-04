import '../models/profile_stats.dart';

/// The contract the Profile tab codes against.
abstract class ProfileRepository {
  Future<ProfileStats> getStats();
}
