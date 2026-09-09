/// The notification feed — Figma "Notification" (page 124:2, `176:24737`).
///
/// The frame is deliberately heterogeneous: some entries are a bare line with
/// an avatar, one is an outlined card, one is a headed block with body copy,
/// and two are plain lines with no avatar at all. Modelling that as a kind per
/// entry is what lets one list render all of them without a pile of nullable
/// flags.
library;

enum NotificationKind {
  /// Avatar, a bold actor, the rest of the line, and a timestamp.
  social,

  /// The outlined "Reminder" card — an unread mark, an icon, a heading and a
  /// line of body.
  reminder,

  /// The weekly digest: an unread mark, an icon, a heading and centred body.
  /// No border in the frame.
  digest,

  /// A line with no avatar, and a timestamp.
  plain,

  /// A line with an inline action beside it — "New article posted / Read".
  action,
}

/// Which filter chip an entry belongs to.
enum NotificationFilter {
  all('All'),
  myPost('My post'),
  mentions('Mentions');

  const NotificationFilter(this.label);

  final String label;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.at,
    this.actor = '',
    this.text = '',
    this.title = '',
    this.body = '',
    this.avatarAsset = '',
    this.iconAsset = '',
    this.actionLabel = '',
    this.unread = false,
    this.filters = const {NotificationFilter.all},
  });

  final String id;
  final NotificationKind kind;

  /// Bold lead-in — the person who did the thing. Empty on entries the frame
  /// writes without one.
  final String actor;

  /// What follows the actor, in regular weight.
  final String text;

  /// [NotificationKind.reminder] and [NotificationKind.digest] only.
  final String title;
  final String body;

  final String avatarAsset;
  final String iconAsset;

  /// The inline link on an [NotificationKind.action] entry.
  final String actionLabel;

  final DateTime at;

  /// Drawn as the frame's red dot.
  final bool unread;

  /// Which chips this entry survives. Everything is in [NotificationFilter.all].
  final Set<NotificationFilter> filters;

  /// "45 minutes ago", "Yesterday", "2 days ago".
  ///
  /// Computed rather than stored: the frame writes "45minutes ago" and
  /// "1 days ago", which are typos, and a stored string would go stale the
  /// moment the screen is opened twice.
  String ago(DateTime now) {
    final d = now.difference(at);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes} minutes ago';
    if (d.inHours < 24) {
      return d.inHours == 1 ? '1 hour ago' : '${d.inHours} hours ago';
    }
    if (d.inDays == 1) return 'Yesterday';
    return '${d.inDays} days ago';
  }
}
