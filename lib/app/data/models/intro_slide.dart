/// One panel of the "Welcome to Soothify" carousel.
///
/// Artwork comes from the Figma section "Mobile / splash screen + Onboarding
/// screen" (655:5253, 655:5273, 655:5294); the copy is the designer's rewrite
/// of 2026-10-07, which also settled the third panel — the file had been
/// repeating the second one's body there.
class IntroSlide {
  const IntroSlide({
    required this.title,
    required this.body,
    required this.assetPath,
  });

  final String title;
  final String body;
  final String assetPath;

  static const List<IntroSlide> all = [
    IntroSlide(
      title: 'Your quiet space.',
      body: 'Connect with guides who speak your language for grounding '
          'sessions to soften stress and protect your peace.',
      assetPath: 'assets/images/onboarding/therapy.png',
    ),
    IntroSlide(
      title: 'Stillness on your terms.',
      body: 'Explore guided sessions in your language to quiet the noise, '
          'sharpen your focus, and return to your centre.',
      assetPath: 'assets/images/onboarding/meditation.png',
    ),
    IntroSlide(
      title: 'Breathe alongside others.',
      body: 'Find a quiet circle of shared experiences, gentle '
          'accountability, and collective grounding.',
      assetPath: 'assets/images/onboarding/community.png',
    ),
  ];
}
