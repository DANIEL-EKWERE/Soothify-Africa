/// One bookable session type on the Schedule screen.
enum SessionOffering {
  therapy('therapy', 'Therapy sessions'),
  meditation('meditation', 'Meditation session'),
  balance('balance', 'Balance sessions');

  const SessionOffering(this.id, this.title);

  final String id;
  final String title;

  /// The design prints the same blurb on all three cards.
  String get blurb => 'One on one session with a\nprofessional';
}
