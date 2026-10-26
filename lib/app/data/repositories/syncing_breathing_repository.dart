import '../../core/errors/app_exception.dart';
import '../../core/utils/logger.dart';
import 'breathing_repository.dart';

/// The breathing streak, on the device and on the account.
///
/// The device answers first and always: a minute finished on a train is
/// finished, and the number should appear the moment it is, not after a
/// round trip. The account is what makes it survive a reinstall.
///
/// Where the two disagree the higher count wins. A device that has just
/// been set up knows nothing and would otherwise reset a streak somebody
/// kept for a month; a device that was offline for a week knows more than
/// the server does. Taking the larger is right in both directions.
class SyncingBreathingRepository implements BreathingRepository {
  SyncingBreathingRepository(
    this._local,
    this._remote, {
    required this.signedIn,
  });

  final BreathingRepository _local;
  final BreathingRepository _remote;

  /// Whether there is an account to ask. A function, not a flag: this is
  /// built once at startup and outlives the sign-in that changes it.
  final bool Function() signedIn;

  @override
  Future<BreathingState> state({DateTime? now}) async {
    final mine = await _local.state(now: now);
    if (!signedIn()) return mine;

    try {
      final theirs = await _remote.state(now: now);
      return theirs.streak >= mine.streak ? theirs : mine;
    } on AppException catch (error) {
      Log.e('could not read the breathing streak', error: error);
      return mine;
    }
  }

  @override
  Future<BreathingState> recordMinute({int seconds = 60, DateTime? now}) async {
    // Written here first, and the caller is answered from it.
    final mine = await _local.recordMinute(seconds: seconds, now: now);
    if (!signedIn()) return mine;

    try {
      final theirs = await _remote.recordMinute(seconds: seconds, now: now);
      return theirs.streak >= mine.streak ? theirs : mine;
    } on AppException catch (error) {
      // Kept on the phone either way. It is one row short on the server
      // until the next one lands, which is a smaller wrong than losing it.
      Log.e('breathing minute not sent yet', error: error);
      return mine;
    }
  }
}
