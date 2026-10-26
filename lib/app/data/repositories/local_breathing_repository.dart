import '../../core/utils/pref_utils.dart';
import 'breathing_repository.dart';

/// The streak as the phone knows it.
///
/// Still the first answer the screen gets: a minute finished on a train is
/// finished whatever the network thinks, and the number should not wait on
/// a round trip to appear.
class LocalBreathingRepository implements BreathingRepository {
  @override
  Future<BreathingState> state({DateTime? now}) async =>
      BreathingState(streak: PrefUtils().breatheStreak());

  @override
  Future<BreathingState> recordMinute({int seconds = 60, DateTime? now}) async {
    final streak = await PrefUtils().recordBreatheDay(now: now);
    return BreathingState(streak: streak);
  }
}
