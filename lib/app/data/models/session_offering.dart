/// One bookable session type on the Schedule screen.
enum SessionOffering {
  therapy('therapy', 'Therapy sessions',
      single: 25000,
      monthly: 75000,
      matchingTitle: 'Finding your therapist'),
  meditation('meditation', 'Pilates & Core session', single: 10000,
      monthly: 36000,
      matchingTitle: 'Finding your Pilates instructor'),
  balance('balance', 'Stretch & Restore sessions',
      single: 10000,
      monthly: 36000,
      matchingTitle: 'Finding your instructor');

  const SessionOffering(
    this.id,
    this.title, {
    required this.single,
    required this.monthly,
    this.matchingTitle = '',
  });

  final String id;
  final String title;

  /// One 50-minute session, in naira.
  final int single;

  /// Unlimited sessions for a month, in naira.
  final int monthly;

  /// The design prints the same blurb on all three cards.
  String get blurb => 'One on one session with a\nprofessional';

  /// The heading on the matching interstitial.
  ///
  /// Read once, from `Matching pilates instructor` (259:58806): **"Finding
  /// your Pilates instructor"**. The other two frames close their own KYC
  /// rows — `Matching Therapist` (259:58834) and `Matching instructor`
  /// (259:58748) — and neither could be fetched.
  ///
  /// Their lines here are **derived from that pattern and those frame
  /// names**, not read: "Finding your " plus what the frame calls the person.
  /// That is a guess, but a much closer one than the previous fallback, which
  /// was the old file's generic sentence and matched no frame at all.
  final String matchingTitle;

  /// What the matching interstitial shows, per discipline where it is known.
  String get matchingHeading => matchingTitle.isNotEmpty
      ? matchingTitle
      : 'Pairing you with a wellness coach who suits your needs.';

}

/// Which of the two prices on the booking screen is chosen.
enum SessionPlan { single, monthly }
