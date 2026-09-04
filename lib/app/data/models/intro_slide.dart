/// One panel of the "Welcome to Soothify" carousel.
///
/// Copy and artwork come from the Figma section
/// "Mobile / splash screen + Onboarding screen" (655:5253, 655:5273, 655:5294).
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
      title: 'Personalized Therapy',
      body: 'Connect with therapists who speak your language for regular '
          'sessions to manage stress and improve mental health.',
      assetPath: 'assets/images/onboarding/therapy.png',
    ),
    IntroSlide(
      title: 'Guided Meditation',
      body: 'Access guided meditation sessions in your language to reduce '
          'stress and enhance focus through daily mindfulness exercises.',
      assetPath: 'assets/images/onboarding/meditation.png',
    ),
    IntroSlide(
      // The design repeats slide 2's body here, which reads like a
      // copy-paste left in the file rather than final copy for Community.
      title: 'Community',
      body: 'Access guided meditation sessions in your language to reduce '
          'stress and enhance focus through daily mindfulness exercises.',
      assetPath: 'assets/images/onboarding/community.png',
    ),
  ];
}
