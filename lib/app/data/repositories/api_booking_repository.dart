import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/booked_session.dart';
import '../models/call_credentials.dart';
import 'booking_repository.dart';

/// Booking against `/api/v1/experts/` and `/api/v1/sessions/`.
class ApiBookingRepository implements BookingRepository {
  ApiBookingRepository(this._api);

  final ApiClient _api;

  @override
  Future<MatchedExpert?> match({
    required String discipline,
    DateTime? day,
    int? startMinute,
    String? language,
  }) async {
    final query = <String, String>{
      'discipline': discipline,
      if (day != null) 'day': _day(day),
      if (startMinute != null) 'start_minute': '$startMinute',
      if (language != null && language.isNotEmpty) 'language': language,
    };

    try {
      final body = await _api.get('/experts/match/?${_encode(query)}');
      return MatchedExpert.fromJson(body);
    } on NotFoundException {
      // Nobody free then. The screen offers another time; it is not a fault.
      return null;
    }
  }

  @override
  Future<List<FreeSlot>> freeSlots(
    String expertId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final query = <String, String>{
      if (from != null) 'from': _day(from),
      if (to != null) 'to': _day(to),
    };
    final rows = await _api.getList(
      '/experts/$expertId/slots/${query.isEmpty ? '' : '?${_encode(query)}'}',
    );
    return rows.map(FreeSlot.fromJson).toList();
  }

  @override
  Future<BookedSession> book({
    required String discipline,
    required DateTime day,
    required int startMinute,
    String mode = 'video',
    String plan = 'single',
    String? expertId,
  }) async {
    final body = await _api.post('/sessions/', body: {
      'discipline': discipline,
      'day': _day(day),
      'start_minute': startMinute,
      'mode': mode,
      'plan': plan,
      if (expertId != null) 'expert': int.tryParse(expertId) ?? expertId,
    });
    return BookedSession.fromJson(body);
  }

  @override
  Future<List<BookedSession>> mySessions({bool upcomingOnly = false}) async {
    final rows = await _api.getList(
      '/sessions/${upcomingOnly ? '?upcoming=true' : ''}',
    );
    return rows.map(BookedSession.fromJson).toList();
  }

  @override
  Future<BookedSession> cancel(String sessionId) async {
    final body = await _api.post('/sessions/$sessionId/cancel/');
    return BookedSession.fromJson(body);
  }

  @override
  Future<BookedSession> rate(
    String sessionId,
    int stars, {
    String feedback = '',
  }) async {
    final body = await _api.post(
      '/sessions/$sessionId/rating/',
      body: {'rating': stars, 'feedback': feedback},
    );
    return BookedSession.fromJson(body);
  }

  @override
  Future<CallCredentials> callToken(String sessionId) async =>
      CallCredentials.fromJson(
        await _api.post('/sessions/$sessionId/call-token/'),
      );

  String _day(DateTime when) {
    final local = when.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  String _encode(Map<String, String> query) => query.entries
      .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
      .join('&');
}
