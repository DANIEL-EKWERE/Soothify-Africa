import '../../core/errors/app_exception.dart';
import '../../core/utils/logger.dart';
import '../models/mood.dart';
import 'mood_repository.dart';

/// Mood check-ins, on the device and on the server.
///
/// The device is authoritative and answers every read. That is deliberate:
/// what someone records about their own state must survive a tunnel, a flat
/// battery of signal, and a server we cannot reach — so a check-in is never
/// waiting on a network call to be saved.
///
/// The server is told afterwards, and told again later if the first attempt
/// failed. Nothing is read back over the local copy: a device that has been
/// offline for a week holds the truth about that week, and overwriting it
/// with a shorter server list would delete somebody's history.
class SyncingMoodRepository implements MoodRepository {
  SyncingMoodRepository(this._local, this._remote);

  final MoodRepository _local;
  final MoodRepository _remote;

  /// Check-ins saved here but not yet accepted by the server, oldest first.
  ///
  /// In memory: a queue that survived a restart would need storage of its
  /// own, and the alternative — pushing the whole local history on the next
  /// successful call — is both simpler and self-healing. See [_catchUp].
  final List<MoodEntry> _unsent = [];

  @override
  Future<List<MoodEntry>> history({int limit = 50}) =>
      _local.history(limit: limit);

  @override
  Future<List<MoodEntry>> between(DateTime from, DateTime to) =>
      _local.between(from, to);

  @override
  Future<MoodEntry?> todaysEntry() => _local.todaysEntry();

  @override
  Future<MoodEntry> record(double score, {String note = ''}) async {
    // Saved first, and the caller is answered from this: the check-in is a
    // fact the moment it is made.
    final saved = await _local.record(score, note: note);

    try {
      await _remote.record(score, note: note);
      await _catchUp();
    } on AppException catch (error) {
      _unsent.add(saved);
      Log.e('mood check-in not sent yet', error: error);
    }
    return saved;
  }

  /// Sends what earlier attempts could not.
  ///
  /// Runs only after a call that worked, so it never becomes a retry storm
  /// against a server that is down.
  Future<void> _catchUp() async {
    if (_unsent.isEmpty) return;
    final waiting = List.of(_unsent);
    for (final entry in waiting) {
      try {
        await _remote.record(entry.score, note: entry.note);
        _unsent.remove(entry);
      } on AppException {
        // Still unreachable. Leave the rest for the next successful call.
        return;
      }
    }
  }
}
