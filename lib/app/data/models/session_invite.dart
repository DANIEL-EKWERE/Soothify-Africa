import 'session_offering.dart';

/// A booked session, as the notification feed hands it to the joining screen.
///
/// The feed knows the discipline and when it is; the joining screen needs
/// those plus who it is with. Nothing schedules sessions yet, so the expert
/// and the hour come from the notification's own copy.
class SessionInvite {
  const SessionInvite({
    required this.expertName,
    required this.service,
    required this.time,
    required this.date,
    this.offering = SessionOffering.therapy,
    this.sessionId = '',
  });

  final String expertName;
  final String service;
  final String time;
  final String date;
  final SessionOffering offering;

  /// The server's id for this session, when the push carried one.
  ///
  /// Empty from the in-app feed, which builds an invite out of the
  /// notification's own copy rather than from a scheduled session — there
  /// is no id there to pass on. The rating at the end of the call is sent
  /// only when this is set; see BookingController.post.
  final String sessionId;
}
