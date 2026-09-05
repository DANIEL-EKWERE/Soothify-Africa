/// The four things Profile tracks — Figma "Profile/mood checkin" (135:8202).
///
/// The design gives all four the same blurb and button; only the heading
/// differs, so they are one card rendered four times rather than four cards.
enum CheckinKind {
  mood('Mood Check-Ins'),
  journal('Journal Check-Ins'),
  meditation('Daily Meditation'),
  balance('Daily Balance');

  const CheckinKind(this.title);

  final String title;

  /// The design prints this identical line under every heading.
  String get blurb => 'Document your thoughts\non daily basis';
}
