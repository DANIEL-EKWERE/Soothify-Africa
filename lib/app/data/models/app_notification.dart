/// The notification feed — Figma "Notification" (page 124:2, `176:24737`
/// for the social rows and `259:61271` for the booking ones).
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

  /// A compact outlined pill — an unread dot, the kind, then one line about a
  /// session. Figma `259:61271`, which fills the feed with these under its
  /// own two chips.
  booking,
}

/// Which filter chip an entry belongs to.
///
/// Two frames draw this row and both lead with "All": `176:24737` adds the
/// social pair, `259:61271` the scheduling pair. They are one feed with four
/// filters rather than two screens — the second frame's rows are simply all
/// of the one kind its chips select.
enum NotificationFilter {
  all('All'),
  sessions('Sessions'),
  whatsNew("What's new", badge: true);

  const NotificationFilter(this.label, {this.badge = false});

  final String label;

  /// Whether the chip carries the small "New" tag beside its label. Only
  /// "What's new" does.
  final bool badge;
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
    this.emphasis = '',
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

  /// [NotificationKind.reminder], [NotificationKind.digest] and
  /// [NotificationKind.booking]. On a booking row it is the kind itself —
  /// "Booking" or "Reminder" — which the frame prints beside the line.
  final String title;
  final String body;

  /// A run inside [body] the design sets in bold — Figma `259:61271` bolds
  /// the discipline in "You have a **Yoga** session on 28 Sep 2026 at
  /// 5:00pm" and leaves the rest regular, in the same ink.
  ///
  /// Empty means the line is all one weight.
  final String emphasis;

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

/// Splits [AppNotification.body] into runs, so the emphasised part can be
/// drawn bold without the model carrying spans.
///
/// Returns the text before the run, the run itself, and the text after. With
/// no emphasis — or an emphasis the body does not contain — the whole line
/// comes back as the first part.
({String before, String bold, String after}) splitEmphasis(
  AppNotification n,
) {
  if (n.emphasis.isEmpty) return (before: n.body, bold: '', after: '');
  final at = n.body.indexOf(n.emphasis);
  if (at < 0) return (before: n.body, bold: '', after: '');
  return (
    before: n.body.substring(0, at),
    bold: n.emphasis,
    after: n.body.substring(at + n.emphasis.length),
  );
}
