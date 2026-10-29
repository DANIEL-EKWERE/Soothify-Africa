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

  /// The card the frame opens with: a 342x77 outline holding an avatar, a
  /// bold heading over two lines, and a two-line body. Re-measured on
  /// 2026-10-02; it was missing from the feed entirely.
  recommendation,

  /// "Reminder". The frame draws it as the same 342x39 pill as [booking], not
  /// as its own taller card — the card shape came from an older revision.
  reminder,

  /// The weekly digest: an unread mark, an icon, a bold heading and a
  /// left-aligned body, inside a 342x62 outline.
  digest,

  /// A line with no avatar, and a timestamp.
  plain,

  /// A line with an inline action beside it — "New article posted / Read".
  action,

  /// The 60-second breathing minute, which arrives as a push and also sits
  /// in the feed — Figma's "Push Notification" section. Same shape as
  /// [action]; the link opens the minute rather than an article.
  breathe,

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
  whatsNew("What's new");

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
    this.emphasis = '',
    this.avatarAsset = '',
    this.iconAsset = '',
    this.actionLabel = '',
    this.unread = false,
    this.filters = const {NotificationFilter.all},
    this.target = '',
  });

  /// Where tapping it goes, as the server wrote it — 'session/8',
  /// 'breathe', 'daily'. Dropped on the way in until now, which is why a
  /// session row had no idea which session it was about and the waiting
  /// room was built out of the row's own words.
  final String target;

  /// The id in a 'session/8' target, or empty.
  String get sessionId =>
      target.startsWith('session/') ? target.substring('session/'.length) : '';

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

  /// Keys are snake_case to match what DRF serves. `kind` and the strings in
  /// `filters` are the server's own enum values, so an unknown one -- a kind
  /// added server-side before the app ships -- falls back to a plain line
  /// rather than crashing the feed.
  /// The same row, read.
  ///
  /// Marking one read is a server call; the screen should not wait for it to
  /// come back before the dot goes away, so the list is rebuilt with this.
  AppNotification markedRead() => AppNotification(
        id: id,
        kind: kind,
        at: at,
        actor: actor,
        text: text,
        title: title,
        body: body,
        emphasis: emphasis,
        avatarAsset: avatarAsset,
        iconAsset: iconAsset,
        actionLabel: actionLabel,
        unread: false,
        filters: filters,
        // Carried, or a row forgets which session it is about the moment
        // it is read.
        target: target,
      );

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final kindName = json['kind'] as String? ?? '';
    final filterNames = (json['filters'] as List?)?.map((f) => '$f').toSet() ??
        const <String>{};

    return AppNotification(
      id: '${json['id']}',
      kind: NotificationKind.values.firstWhere(
        (k) => k.name == kindName,
        orElse: () => NotificationKind.plain,
      ),
      actor: json['actor'] as String? ?? '',
      text: json['text'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      emphasis: json['emphasis'] as String? ?? '',
      actionLabel: json['action_label'] as String? ?? '',
      unread: json['unread'] as bool? ?? false,
      at: DateTime.tryParse('${json['created_at']}')?.toLocal() ??
          DateTime.now(),
      filters: {
        NotificationFilter.all,
        for (final name in filterNames)
          if (_filterFor(name) != null) _filterFor(name)!,
      },
    );
  }

  /// The server writes "whats_new"; the enum spells it `whatsNew`.
  static NotificationFilter? _filterFor(String name) {
    switch (name) {
      case 'sessions':
        return NotificationFilter.sessions;
      case 'whats_new':
        return NotificationFilter.whatsNew;
      default:
        return null;
    }
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
