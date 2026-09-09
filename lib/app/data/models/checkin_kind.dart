/// The four things Profile tracks — Figma "Profile/mood checkin" (135:8202).
///
/// The design gives all four the same blurb and button; only the heading
/// differs, so they are one card rendered four times rather than four cards.
enum CheckinKind {
  mood('Mood Check-Ins', 'assets/images/checkin/ic_mood.png'),
  journal('Journal Check-Ins', 'assets/images/checkin/ic_journal.png'),
  // The frame draws the Explore tiles here, so they are reused rather than
  // exported twice.
  meditation('Daily Pilates & Core', 'assets/images/explore/meditation.png'),
  balance('Daily Stretch & Restore', 'assets/images/explore/balance.png');

  const CheckinKind(this.title, this.iconAsset);

  final String title;

  /// The badge above the title on a Check-Ins card.
  final String iconAsset;

  /// The design prints this identical line under every heading.
  String get blurb => 'Document your thoughts\non daily basis';
}
