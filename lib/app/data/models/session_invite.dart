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
  });

  final String expertName;
  final String service;
  final String time;
  final String date;
  final SessionOffering offering;
}
