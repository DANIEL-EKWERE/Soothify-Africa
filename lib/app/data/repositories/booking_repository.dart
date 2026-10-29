import '../models/booked_session.dart';
import '../models/call_credentials.dart';

/// Matching, booking and the sessions that come of it.
///
/// An interface so the booking screens can be driven in a test without a
/// server, and so the flow can be walked offline against a stand-in.
abstract class BookingRepository {
  /// Who the client would be paired with, and how close the match is.
  ///
  /// Returns null when nobody practises that discipline at that hour, which
  /// is an answer the screen has to show rather than an error.
  Future<MatchedExpert?> match({
    required String discipline,
    DateTime? day,
    int? startMinute,
    String? language,
  });

  /// The hours an expert is free, for the calendar.
  Future<List<FreeSlot>> freeSlots(String expertId, {DateTime? from, DateTime? to});

  /// Hold a slot. The session comes back awaiting payment -- booking and
  /// paying are two steps, and the hold expires if the second never comes.
  Future<BookedSession> book({
    required String discipline,
    required DateTime day,
    required int startMinute,
    String mode = 'video',
    String plan = 'single',
    String? expertId,
  });

  Future<List<BookedSession>> mySessions({bool upcomingOnly = false});

  Future<BookedSession> cancel(String sessionId);

  Future<BookedSession> rate(String sessionId, int stars, {String feedback = ''});

  /// Credentials for joining the call. Only issued to the two people on the
  /// booking, and only around the time it runs.
  /// Credentials for joining this session's call.
  ///
  /// Minted per person and only around the time the session runs -- the
  /// server refuses outside that window, with a line saying when the room
  /// opens. Throws [AppException] carrying that line.
  Future<CallCredentials> callToken(String sessionId);
}
