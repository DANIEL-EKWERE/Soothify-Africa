import '../models/mood.dart';

/// Contract for recording and reading mood check-ins.
///
/// Screens depend on this, never on storage or HTTP, so the local
/// implementation can be swapped for the Django-backed one without touching
/// any UI code.
abstract class MoodRepository {
  /// Most recent first.
  Future<List<MoodEntry>> history({int limit = 50});

  Future<MoodEntry> record(Mood mood, {String note = ''});

  /// Entries falling on the days from [from] to [to] inclusive. Used by the
  /// mood-record week strip.
  Future<List<MoodEntry>> between(DateTime from, DateTime to);

  /// The entry logged today, if there is one — the check-in screen uses this
  /// to preselect and to avoid duplicate entries for the same day.
  Future<MoodEntry?> todaysEntry();
}
