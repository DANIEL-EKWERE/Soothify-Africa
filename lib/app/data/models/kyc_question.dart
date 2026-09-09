/// How a question's answers behave.
enum KycInput {
  /// Any number of options; Next unlocks once one is chosen.
  multi,

  /// Exactly one option.
  single,

  /// A scrolling wheel of values, always with something selected.
  wheel,

  /// A full-bleed swipeable carousel of illustrations, one per option, on the
  /// focused option's own background colour. Multi-select, like [multi].
  ///
  /// Only "What brings you to Soothify?" uses it — Figma "Kyc screen | Stress"
  /// (`176:23723`) and "| Anxiety" (`176:56150`).
  carousel,
}

class KycOption {
  const KycOption(
    this.value,
    this.label, {
    this.assetPath,
    this.illustration,
    this.backgroundArgb,
    this.accentArgb,
  });

  /// Persisted and sent to the API; never displayed.
  final String value;

  final String label;

  /// 30x30 icon shown at the head of the row, where the design has one.
  final String? assetPath;

  /// [KycInput.carousel] only — the full character illustration, the colour
  /// the screen floods behind it, and the colour its progress bar fills with.
  ///
  /// Held as ARGB ints so the data layer stays free of Flutter types, as the
  /// other models here do.
  final String? illustration;
  final int? backgroundArgb;
  final int? accentArgb;
}

/// One step of the KYC questionnaire.
///
/// The design draws six of these as separate frames in "Mobile / KYC"; they
/// differ only in prompt, options and input type, so one screen renders them
/// all rather than six near-identical screens.
class KycQuestion {
  const KycQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    this.input = KycInput.single,
    this.subtitle,
  });

  final String id;
  final String prompt;
  final String? subtitle;
  final List<KycOption> options;
  final KycInput input;

  /// Carousel answers toggle the same way the tile list's do.
  bool get isMulti =>
      input == KycInput.multi || input == KycInput.carousel;

  static const String _multiHint = 'You Can Select More Than One Option';

  static final List<KycQuestion> all = [
    const KycQuestion(
      id: 'concerns',
      prompt: 'What brings you to Soothify?',
      subtitle: _multiHint,
      // Illustrations on a flooded background, not the emoji tiles the older
      // file drew. Colours sampled from the frames.
      input: KycInput.carousel,
      options: [
        KycOption('stress', 'Stress',
            illustration: 'assets/images/concerns/stress_figure.png',
            backgroundArgb: 0xFFF9980F,
            accentArgb: 0xFF4679ED),
        KycOption('anxiety', 'Anxiety',
            illustration: 'assets/images/concerns/anxiety_figure.png',
            backgroundArgb: 0xFF7B7FE8,
            accentArgb: 0xFFFFAE24),
        // The remaining two frames (`176:56161`, `176:56173`, both misnamed
        // "Anxiety") have not been rendered — the Figma image endpoint is
        // rate-limited. Until they are, these two carry no illustration and
        // fall back to the brand background.
        KycOption('sleep_disorder', 'Sleep disorder'),
        KycOption('depression', 'Depression'),
      ],
    ),
    const KycQuestion(
      id: 'frequency',
      prompt: 'How often do you experience symptoms related to stress, '
          'anxiety, or depression?',
      options: [
        KycOption('regularly', 'Regularly'),
        KycOption('not_regularly', 'Not regularly'),
        KycOption('not_at_all', 'Not at all'),
      ],
    ),
    const KycQuestion(
      id: 'in_treatment',
      prompt: 'Are you currently undergoing treatment for any mental health '
          'condition?',
      options: [
        KycOption('yes', 'Yes'),
        KycOption('no', 'No'),
      ],
    ),
    const KycQuestion(
      id: 'goals',
      prompt: 'What are the goals or outcomes you hope to achieve?',
      subtitle: _multiHint,
      input: KycInput.multi,
      options: [
        KycOption('career', 'My career/performance',
            assetPath: 'assets/images/goals/career.png'),
        KycOption('romance', 'My romantic relationship',
            assetPath: 'assets/images/goals/romance.png'),
        KycOption('friendship', 'My friendship/family relations',
            assetPath: 'assets/images/goals/friendship.png'),
        KycOption('peace', 'My peace of mind',
            assetPath: 'assets/images/goals/peace.png'),
        KycOption('something_else', 'Something else',
            assetPath: 'assets/images/goals/something_else.png'),
      ],
    ),
    const KycQuestion(
      id: 'gender',
      prompt: 'What is your gender?',
      options: [
        KycOption('male', 'Male'),
        KycOption('female', 'Female'),
        KycOption('non_binary', 'Non binary'),
        KycOption('undisclosed', 'Rather not say'),
      ],
    ),
    KycQuestion(
      id: 'age',
      prompt: 'How old are you?',
      input: KycInput.wheel,
      // The design lists 18 through 50.
      options: [
        for (var age = 18; age <= 50; age++)
          KycOption('$age', '$age'),
      ],
    ),
  ];
}
