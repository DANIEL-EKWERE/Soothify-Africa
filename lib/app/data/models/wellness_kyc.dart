/// The questionnaire a section shows before its booking flow.
///
/// Meditation, Balance and Schedule each gate their sessions behind one, and
/// the questions differ per section — the Meditation set (Figma 135:23097
/// onward) asks about meditation experience, the Schedule set (135:23694
/// onward) about coaching and effort. Only the shape is shared.
class WellnessKycStep {
  const WellnessKycStep({
    required this.question,
    required this.options,
    this.multiSelect = false,
  });

  final String question;
  final List<String> options;

  /// The design marks these with "You can select more than one option".
  final bool multiSelect;
}

/// Which section's questionnaire is running.
enum WellnessTrack {
  meditation(
    'Meditation',
    [
      WellnessKycStep(
        question:
            'What is your primary reason for seeking meditation guidance?',
        // The design writes "Better  sleep" with a double space; normalised.
        options: [
          'Stress relief',
          'Better sleep',
          'Focus and concentration',
          'Emotional well-being',
          'Others',
        ],
      ),
      WellnessKycStep(
        question: 'How familiar are you with meditation practices?',
        options: [
          'New to meditation',
          'Some experience',
          'Regular practice',
          'Advanced practitioner',
        ],
      ),
      WellnessKycStep(
        question: 'What types of meditation are you interested in?',
        options: [
          'Mindfulness',
          'Guided meditation',
          'Mantra meditation',
          'Breathing exercises',
          'Others',
        ],
      ),
      WellnessKycStep(
        question:
            'Do you prefer your meditation sessions in English or Pidgin '
            'English?',
        // The frame lists the *previous* question's options here — a
        // copy-paste slip in the file, since the question asks about
        // language. These are what the question actually calls for; confirm
        // with the designer before launch.
        options: ['English', 'Pidgin English'],
      ),
      WellnessKycStep(
        question:
            'What time of the day do you prefer to schedule your meditation '
            'sessions?',
        options: ['Morning', 'Afternoon', 'Evening', 'No preference'],
      ),
    ],
  ),
  balance(
    'Balance',
    [
      WellnessKycStep(
        question: 'What’s your level of experience with yoga?',
        options: ['Beginner', 'Intermediate', 'Advanced'],
      ),
      WellnessKycStep(
        question: 'What are your goals for practicing yoga?',
        options: ['Stress Relief', 'Flexibility', 'Strength Building'],
        multiSelect: true,
      ),
      WellnessKycStep(
        // The frame writes "yoga  are" with a double space; normalised.
        question: 'What type of yoga are you interested in?',
        options: ['Hatha', 'Vinyasa', 'Ashtanga', 'Others'],
        multiSelect: true,
      ),
      WellnessKycStep(
        question: 'Do you have any specific areas of you’d like to focus on?',
        options: [
          'Knees',
          'Shoulders',
          'Back Pain',
          'Stress Relief',
          'Others',
        ],
        multiSelect: true,
      ),
      WellnessKycStep(
        question: 'How would you rate overall fitness level?',
        options: ['Low', 'Moderate', 'High'],
      ),
      WellnessKycStep(
        question: 'Are you currently pregnant or do you have any preexisting '
            'health conditions?',
        options: ['High Blood Pressure', 'Asthma', 'Others'],
        // The frame omits the "select more than one" hint here, which would
        // make it single-select — but the question is plural and someone can
        // have both. Forcing one answer would under-report a health
        // condition before a physical class, so it is multi. Confirm.
        multiSelect: true,
      ),
    ],
    hasIntro: false,
  ),
  schedule(
    'Schedule',
    [
      WellnessKycStep(
        question: 'What type of wellness sessions are you interested in?',
        options: [
          'Mindfulness',
          'Hatha Yoga',
          'Restorative Yoga',
          'Ashtanga Vinyasa',
          'Anusara',
          'Prenatal Yoga',
        ],
        multiSelect: true,
      ),
      WellnessKycStep(
        question: 'How much effort would you like to put in?',
        options: ['Low', 'Moderate', 'High'],
      ),
      WellnessKycStep(
        question: 'What types of sounds would you enjoy on SoothifyAfrica?',
        options: [
          'sound effects',
          'slow instrumentals',
          'sleep stories',
          'Voice overs',
        ],
        multiSelect: true,
      ),
      WellnessKycStep(
        question: 'In which language would you prefer to take your classes?',
        options: ['English', 'Pidgin'],
      ),
      WellnessKycStep(
        question: 'What type of coaching are you looking for?',
        options: ['Heartfelt', 'Playful', 'Supportive', 'Technical'],
      ),
    ],
  );

  const WellnessTrack(this.title, this.steps, {this.hasIntro = true});

  /// The header title — the frames differ only here, which is why the
  /// Meditation and Schedule intros read identically otherwise.
  final String title;

  final List<WellnessKycStep> steps;

  /// Meditation and Schedule open on the "Tell us a little about yourself"
  /// interstitial; Balance has no such frame and starts on its first
  /// question.
  final bool hasIntro;

  /// The shared intro line, identical across the three sections.
  String get intro =>
      'Tell us a little about yourself, and we’ll match you with the perfect '
      'wellness coach';

  String get prefKey => 'wellnessKyc_$name';
}
