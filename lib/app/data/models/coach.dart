/// The wellness coach a booking is matched with — Figma "Matched with
/// instructor" (135:20932).
class Coach {
  const Coach({
    required this.name,
    required this.matchPercent,
    required this.blurb,
    required this.interests,
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
  final List<String> interests;

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
    blurb: 'We believe that fitness is part of your journey\n'
        'to authenticity.',
    // "Mediatation classes" is misspelt in the file; corrected here.
    interests: [
      'Heartfelt Coaching',
      'Pop Music',
      'Pop Music',
      'Mediatation classes',
      'Yoga',
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
