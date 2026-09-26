/// One bookable session type on the Schedule screen.
enum SessionOffering {
  therapy('therapy', 'Therapy sessions', single: 25000, monthly: 75000),
  meditation('meditation', 'Pilates & Core session', single: 10000,
      monthly: 36000),
  balance('balance', 'Stretch & Restore sessions', single: 10000,
      monthly: 36000);

  const SessionOffering(
    this.id,
    this.title, {
    required this.single,
    required this.monthly,
  });

  final String id;
  final String title;

  /// One 50-minute session, in naira.
  final int single;

  /// Unlimited sessions for a month, in naira.
  final int monthly;

  /// The design prints the same blurb on all three cards.
  String get blurb => 'One on one session with a\nprofessional';

  /// Whether the booking screen spells the refund rules out in a panel.
  ///
  /// The therapist frame (`259:58862`) carries the full Cancellation Policy;
  /// the two track frames (`259:58919`, `259:58941`) reduce it to one line
  /// under the button. Cancelling a paid appointment with a person is the
  /// higher-stakes case, which is presumably why.
  bool get hasCancellationPolicy => this == SessionOffering.therapy;
}

/// Which of the two prices on the booking screen is chosen.
enum SessionPlan { single, monthly }
