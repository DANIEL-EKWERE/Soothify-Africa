import 'app_notification.dart';

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
    this.id = '',
  });

  /// Built from a feed row the server served.
  ///
  /// The expert and the client read the same endpoint -- notifications are
  /// filed against whoever signs in -- so this is a reshaping, not a second
  /// feed. Anything that is not a booking is drawn as a reminder rather
  /// than dropped: this screen has two shapes and an expert missing a row
  /// entirely is worse than one drawn with the wrong icon.
  factory ExpertNotification.fromFeed(AppNotification row) =>
      ExpertNotification(
        id: row.id,
        kind: row.kind == NotificationKind.booking
            ? ExpertNotificationKind.booking
            : ExpertNotificationKind.reminder,
        // `body` on the booking rows the server writes; the social shapes
        // put their words in `text` behind an actor, so fall through both.
        body: row.body.isNotEmpty
            ? row.body
            : [row.actor, row.text].where((s) => s.isNotEmpty).join(' '),
        emphasis: row.emphasis,
        unread: row.unread,
      );

  /// The server's row id, so tapping one can mark it read. Empty on the
  /// rows this app writes itself.
  final String id;

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
