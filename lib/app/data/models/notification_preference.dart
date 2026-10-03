/// The four switches on "Notifications" — Figma `259:37526`.
///
/// Rows at 132, 184, 236 and 288, each 44 tall with its toggle at x=342. The
/// frame draws all four off.
enum NotificationPreference {
  balance('Balance Reminder', 'notify_balance'),
  meditation('Meditation Reminder', 'notify_meditation'),
  mood('Mood check-Ins reminder', 'notify_mood'),
  offers('Promotional Offers', 'notify_offers');

  const NotificationPreference(this.label, this.key);

  final String label;

  /// The preferences key it persists under.
  final String key;
}
