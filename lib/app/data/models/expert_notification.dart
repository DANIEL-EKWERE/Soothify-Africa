/// The expert's notification feed — Figma's expert "Notification" frame.
///
/// A separate model from the client's [AppNotification]: the expert is told
/// about bookings and session reminders, never about comments or posts, and
/// the chips above the list differ too.
enum ExpertNotificationFilter {
  all('All'),
  schedules('Schedules'),
  newBooking('New booking');

  const ExpertNotificationFilter(this.label);

  final String label;
}

enum ExpertNotificationKind {
  booking('Booking'),
  reminder('Reminder');

  const ExpertNotificationKind(this.label);

  final String label;
}

class ExpertNotification {
  const ExpertNotification({
    required this.kind,
    required this.body,
    required this.emphasis,
    this.unread = true,
  });

  final ExpertNotificationKind kind;

  /// The whole line. [emphasis] is the run inside it the design bolds — the
  /// discipline, as on the client's booking rows.
  final String body;
  final String emphasis;

  final bool unread;

  /// Which chips this row survives.
  bool matches(ExpertNotificationFilter filter) => switch (filter) {
        ExpertNotificationFilter.all => true,
        ExpertNotificationFilter.schedules =>
          kind == ExpertNotificationKind.reminder,
        ExpertNotificationFilter.newBooking =>
          kind == ExpertNotificationKind.booking,
      };
}
