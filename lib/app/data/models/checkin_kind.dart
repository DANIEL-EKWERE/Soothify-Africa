/// The things Profile tracks — Figma "Profile/mood checkin" (135:8202).
///
/// The design gives them the same blurb and button; only the heading
/// differs, so they are one card rendered repeatedly rather than four cards.
enum CheckinKind {
  mood('Mood Check-Ins', 'assets/images/checkin/ic_mood.png'),
  journal('Journal Check-Ins', 'assets/images/checkin/ic_journal.png'),
  // The frame draws the Explore tiles here, so they are reused rather than
  // exported twice.
  meditation('Daily Pilates & Core', 'assets/images/explore/meditation.png'),
  balance('Daily Stretch & Restore', 'assets/images/explore/balance.png'),
  // The breathing minute was reachable only by tapping a notification, so
  // anybody who wanted to breathe now, or to keep a streak going, had no
  // way in. This is the section it belongs in: the one that is about
  // habits and their history. The design draws no fifth card.
  breathing('Breathing', 'assets/images/content/breath_work.png');

  const CheckinKind(this.title, this.iconAsset);

  final String title;

  /// The badge above the title on a Check-Ins card.
  final String iconAsset;

  /// The design prints this identical line under every heading. Breathing
  /// is not something you document, so it says what it is instead.
  String get blurb => switch (this) {
        CheckinKind.breathing => 'Take a minute to\nbreathe and settle',
        _ => 'Document your thoughts\non daily basis',
      };
}
