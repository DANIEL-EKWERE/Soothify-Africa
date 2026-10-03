/// The wellness coach a booking is matched with — Figma "Matched with
/// instructor" (135:20932).
class Coach {
  const Coach({
    required this.name,
    required this.matchPercent,
    required this.blurb,
    required this.feelings,
    required this.quote,
    required this.outside,
    required this.expertise,
    required this.videoTitles,
  });

  final String name;

  /// 0-100. The design prints "98% Match".
  final int matchPercent;

  final String blurb;

  /// The "Because you like" chips.
  /// The chips under "Because you feel...".
  final List<String> feelings;

  final String quote;

  /// The "Outside of Soothify" lines.
  final List<String> outside;

  final List<String> expertise;
  final List<String> videoTitles;

  /// The design mixes two names — the header says "Baraqhat Ibrahim" while
  /// "Find Melody Briggs" and one variant's trending row say "Melody Briggs".
  /// One coach is rendered throughout; confirm which name is intended.
  static const Coach sample = Coach(
    name: 'Baraqhat Ibrahim',
    matchPercent: 98,
    // The frame writes "Practicing yoga with Melody Briggs" on Baraqhat's
    // own profile — a name left over from another card. The coach's name is
    // substituted rather than printed as drawn.
    blurb: 'We believe that fitness is part of your journey\n'
        'to authenticity. Practicing yoga with Baraqhat Ibrahim will help '
        'you tap into your emotions, physically challenge yourself, and find '
        'joy in movement,',
    // The chips answer "Because you feel...", so they are moods, not
    // interests. They were "Heartfelt Coaching / Pop Music / Yoga" under an
    // older heading that read "Because you like".
    feelings: [
      'Anxious',
      'Stressed',
      'Low',
      'Drained',
      'Overwhelmed',
    ],
    quote: '“Live your life in your truth.”',
    outside: [
      'Pop music lover',
      'Enjoys being active and spending time with friends',
    ],
    expertise: ['Yoga', 'Meditation'],
    videoTitles: ['Unshakeable', 'Unshakeable', 'Unshakeable'],
  );
}
