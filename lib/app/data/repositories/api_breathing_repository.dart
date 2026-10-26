import '../../core/network/api_client.dart';
import 'breathing_repository.dart';

/// The streak as the account knows it — `/api/v1/wellbeing/breathing/`.
class ApiBreathingRepository implements BreathingRepository {
  ApiBreathingRepository(this._api);

  final ApiClient _api;

  @override
  Future<BreathingState> state({DateTime? now}) async => BreathingState.fromJson(
        await _api.get('/wellbeing/breathing/?day=${_day(now)}'),
      );

  @override
  Future<BreathingState> recordMinute({int seconds = 60, DateTime? now}) async {
    final body = await _api.post('/wellbeing/breathing/', body: {
      'seconds': seconds,
      'day': _day(now),
    });
    return BreathingState.fromJson(body);
  }

  /// The phone's own day, not the server's. It runs on UTC and the people
  /// using it do not, so half past midnight in Lagos would be filed under
  /// yesterday and break a streak somebody had kept. Sent on the read as
  /// well, because that is the day the streak has to be counted back from.
  String _day(DateTime? now) {
    final day = now ?? DateTime.now();
    return '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
  }
}
