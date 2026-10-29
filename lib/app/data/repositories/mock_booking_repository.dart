import '../models/booked_session.dart';
import '../models/call_credentials.dart';
import '../models/coach.dart';
import 'booking_repository.dart';

/// Booking without a server: the frames' own coach, a plain working day of
/// slots, and a session that exists only in memory.
///
/// Deliberately asynchronous and a little slow, so the matching interstitial
/// and the loading states get exercised rather than discovered later.
class MockBookingRepository implements BookingRepository {
  MockBookingRepository({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  static const _latency = Duration(milliseconds: 400);

  final List<BookedSession> _booked = [];
  var _nextId = 1;

  /// The hours the calendar offers. A plain working day, as the design's
  /// own frame could not be read.
  static const _slotMinutes = [9 * 60, 11 * 60, 13 * 60, 15 * 60, 17 * 60, 19 * 60];

  @override
  Future<MatchedExpert?> match({
    required String discipline,
    DateTime? day,
    int? startMinute,
    String? language,
  }) async {
    await Future<void>.delayed(_latency);
    final coach = Coach.sample;
    return MatchedExpert(
      id: '1',
      name: coach.name,
      headline: coach.blurb,
      quote: coach.quote,
      disciplines: [discipline],
      languages: const ['english'],
      // The model renamed these to `feelings` ('Because you like …').
      interests: coach.feelings,
      matchPercent: coach.matchPercent,
    );
  }

  @override
  Future<List<FreeSlot>> freeSlots(
    String expertId, {
    DateTime? from,
    DateTime? to,
  }) async {
    await Future<void>.delayed(_latency);
    final start = from ?? _now();
    return [
      for (var dayOffset = 0; dayOffset < 14; dayOffset++)
        for (final minute in _slotMinutes)
          FreeSlot(
            id: '$dayOffset-$minute',
            day: DateTime(start.year, start.month, start.day)
                .add(Duration(days: dayOffset)),
            startMinute: minute,
            endMinute: minute + 60,
          ),
    ];
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
    await Future<void>.delayed(_latency);
    final startsAt = DateTime(day.year, day.month, day.day)
        .add(Duration(minutes: startMinute));
    final session = BookedSession(
      id: '${_nextId++}',
      discipline: discipline,
      expertName: Coach.sample.name,
      startsAt: startsAt,
      endsAt: startsAt.add(const Duration(minutes: 50)),
      // Awaiting payment, as the real one is: booking holds the hour, and
      // paying is the step that confirms it.
      status: 'pending',
      priceNaira: discipline == 'therapy' ? 25000 : 10000,
      mode: mode,
    );
    _booked.add(session);
    return session;
  }

  @override
  Future<List<BookedSession>> mySessions({bool upcomingOnly = false}) async {
    await Future<void>.delayed(_latency);
    return List.unmodifiable(_booked);
  }

  @override
  Future<BookedSession> cancel(String sessionId) async {
    await Future<void>.delayed(_latency);
    final index = _booked.indexWhere((s) => s.id == sessionId);
    if (index < 0) throw StateError('no session $sessionId');
    final was = _booked[index];
    final now = BookedSession(
      id: was.id,
      discipline: was.discipline,
      expertName: was.expertName,
      startsAt: was.startsAt,
      endsAt: was.endsAt,
      status: 'cancelled',
      priceNaira: was.priceNaira,
      mode: was.mode,
    );
    _booked[index] = now;
    return now;
  }

  @override
  Future<BookedSession> rate(
    String sessionId,
    int stars, {
    String feedback = '',
  }) async {
    await Future<void>.delayed(_latency);
    return _booked.firstWhere((s) => s.id == sessionId);
  }

  @override
  Future<CallCredentials> callToken(String sessionId) async {
    await Future<void>.delayed(_latency);
    // No credentials without a server, and saying so is better than handing
    // back something that cannot join a room.
    throw UnimplementedError('Calls need the backend.');
  }
}
