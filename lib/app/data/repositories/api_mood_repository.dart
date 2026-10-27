import '../../core/network/api_client.dart';
import '../models/mood.dart';
import 'mood_repository.dart';

/// Mood check-ins against `/api/v1/wellbeing/moods/`.
///
/// Rarely used on its own — see [SyncingMoodRepository], which keeps the
/// device's copy authoritative so a check-in survives being offline.
class ApiMoodRepository implements MoodRepository {
  ApiMoodRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<MoodEntry>> history({int limit = 50}) async {
    final rows = await _api.getList('/wellbeing/moods/?limit=$limit');
    return rows.map(MoodEntry.fromJson).toList();
  }

  @override
  Future<MoodEntry> record(double score, {String note = ''}) async {
    final body = await _api.post('/wellbeing/moods/', body: {
      'score': score,
      'note': note,
      // The phone's own day, not the server's. It runs on UTC and the
      // people using it do not: half past midnight in Lagos is still
      // yesterday there, and with one entry per day that overwrote the
      // check-in they had already made.
      'recorded_on': _day(DateTime.now()),
    });
    return MoodEntry.fromJson(body);
  }

  @override
  Future<List<MoodEntry>> between(DateTime from, DateTime to) async {
    final rows = await _api.getList(
      '/wellbeing/moods/?from=${_day(from)}&to=${_day(to)}',
    );
    return rows.map(MoodEntry.fromJson).toList();
  }

  @override
  Future<MoodEntry?> todaysEntry() async {
    // Asked for by the phone's day, for the same reason.
    final body = await _api.get(
      '/wellbeing/moods/today/?day=${_day(DateTime.now())}',
    );
    // The server answers with an empty body when nothing was recorded
    // today, which is a fact rather than a failure.
    if (body.isEmpty || body['id'] == null) return null;
    return MoodEntry.fromJson(body);
  }

  String _day(DateTime when) {
    final local = when.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}
