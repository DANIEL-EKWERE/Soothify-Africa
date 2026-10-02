/// How a question's answers behave.
enum KycInput {
  /// Any number of options; Next unlocks once one is chosen.
  multi,

  /// Exactly one option.
  single,

  /// A wheel of birth *years* beside a live readout of the age they imply —
  /// Figma `259:27860`.
  ///
  /// This replaced a plain wheel of ages 18-50. That `wheel` case is gone
  /// rather than kept unused: with no branch for it left in the screen, a
  /// question declaring it would silently render as a list of tiles.
  birthYear,

  /// A full-bleed swipeable carousel of illustrations, one per option, on the
  /// focused option's own background colour. Multi-select, like [multi].
  ///
  /// Only "What brings you to your space today?" uses it — Figma
  /// "Kyc screen | Stress"
  /// (`176:23723`) and "| Anxiety" (`176:56150`).
  carousel,
}

class KycOption {
  const KycOption(
    this.value,
    this.label, {
    this.assetPath,
    this.illustration,
    this.illustrationMale,
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

  /// The male counterpart of [illustration] — the frames draw the carousel
  /// twice, once per figure (`191:36092`-`191:36125` are his). Null falls
  /// back to the female art.
  final String? illustrationMale;

  final int? backgroundArgb;
  final int? accentArgb;

  /// Which illustration to draw for the gender the user gave a step earlier.
  /// Anything that is not an explicit "male" — female, non-binary,
  /// undisclosed — gets the female set, as the Mood Checker does.
  String? illustrationFor(String? gender) =>
      gender == 'male' ? (illustrationMale ?? illustration) : illustration;
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

  /// The carousel's own hint, in the title case the frames set it in.
  static const String _carouselHint = 'You can select more than one option';

  /// The list questions' hint, rewritten with the rest of the copy.
  static const String _multiHint = '(Select what applies)';

  static List<KycQuestion> allFor(int currentYear) => [
    // First, before the concerns carousel: its answer decides whether the
    // carousel draws the male or the female set of illustrations, so it has
    // to be known by the time that step is reached.
    const KycQuestion(
      id: 'gender',
      // `259:27844`. Was "What is your gender?" with "Non binary" and
      // "Rather not say".
      prompt: 'How do you identify?',
      options: [
        KycOption('male', 'Male'),
        KycOption('female', 'Female'),
        KycOption('non_binary', 'Non-binary'),
        KycOption('undisclosed', 'Prefer not to say'),
      ],
    ),
    const KycQuestion(
      id: 'concerns',
      // `259:58499` onward. Was "What brings you to Soothify?".
      prompt: 'What brings you to your space today?',
      subtitle: _carouselHint,
      // Illustrations on a flooded background, not the emoji tiles the older
      // file drew. Colours sampled from the four frames.
      //
      // The accent contrasts the flood rather than matching it: amber on
      // every ground. The stress panel used to be amber and took a blue
      // accent for that reason; its ground is `#2F6FED` now, and `259:58499`
      // still carries the old `#4679ED` accent — blue on blue, all but
      // invisible. Read as a leftover from the colour change, so it takes
      // amber like the other three. Confirm with the designer.
      input: KycInput.carousel,
      options: [
        KycOption('stress', 'Carrying heavy stress',
            illustration: 'assets/images/concerns/stress_figure.png',
            illustrationMale: 'assets/images/concerns/stress_figure_male.png',
            // Was amber (`#F9980F`); `259:58499` floods brand blue now.
            backgroundArgb: 0xFF2F6FED,
            accentArgb: 0xFFFFAE24),
        KycOption('anxiety', 'Navigating anxiety',
            illustration: 'assets/images/concerns/anxiety_figure.png',
            illustrationMale: 'assets/images/concerns/anxiety_figure_male.png',
            backgroundArgb: 0xFF7B7FE8,
            accentArgb: 0xFFFFAE24),
        // `176:56173` and `176:56161`, both misnamed "Kyc screen | Anxiety"
        // in the file — the names are duplicates, the artwork is not.
        KycOption('sleep_disorder', 'Restless sleep',
            illustration: 'assets/images/concerns/sleep_disorder_figure.png',
            illustrationMale: 'assets/images/concerns/sleep_disorder_figure_male.png',
            backgroundArgb: 0xFF465A8C,
            accentArgb: 0xFFFFAE24),
        KycOption('depression', 'Low energy or burnout',
            illustration: 'assets/images/concerns/depression_figure.png',
            illustrationMale: 'assets/images/concerns/depression_figure_male.png',
            backgroundArgb: 0xFF626A8A,
            accentArgb: 0xFFFFAE24),
      ],
    ),
    const KycQuestion(
      id: 'frequency',
      // `259:27752`. Was "How often do you experience symptoms related to
      // stress, anxiety, or depression?" — Regularly / Not regularly / Not at
      // all. "this" now refers back to whatever the carousel just collected.
      prompt: 'How often does this show up in your daily life?',
      options: [
        KycOption('often', 'Often'),
        KycOption('sometimes', 'Sometimes'),
        KycOption('passing', 'Just passing through'),
      ],
    ),
    const KycQuestion(
      id: 'in_treatment',
      // `259:27780`. Was "Are you currently undergoing treatment for any
      // mental health condition?" — the new wording asks the same thing
      // without naming it a condition.
      prompt: 'Are you currently working with a care provider or therapist '
          'elsewhere?',
      options: [
        KycOption('yes', 'Yes'),
        KycOption('no', 'No'),
      ],
    ),
    const KycQuestion(
      id: 'goals',
      // `259:27804` / `27824`. Was "What are the goals or outcomes you hope
      // to achieve?" over five options with a 30px icon each; the new rows
      // carry no artwork, so the goal images are no longer referenced.
      prompt: 'What are you hoping to cultivate here?',
      subtitle: _multiHint,
      input: KycInput.multi,
      options: [
        KycOption('clarity', 'Mental clarity & performance'),
        KycOption('relationships', 'Grounding in relationships'),
        KycOption('boundaries', 'Boundaries with family & friends'),
        KycOption('peace', 'Inner calm & peace of mind'),
        KycOption('something_else', 'Something else'),
      ],
    ),
    KycQuestion(
      id: 'birth_year',
      prompt: 'What is your age?',
      input: KycInput.birthYear,
      // Newest year first, the order the frame lists them in: 1995 above
      // 1994 above the boxed 1993.
      //
      // The wheel runs *past* the minimum age rather than stopping at it. A
      // list that simply ends at 18 gives someone younger nothing to scroll
      // to and no reason why; offering the years and refusing them says what
      // the rule is. See [isUnderage].
      options: [
        for (var year = currentYear - youngestOffered;
            year >= currentYear - maxAge;
            year--)
          KycOption('$year', '$year'),
      ],
    ),
  ];

  /// The questionnaire against the current year.
  ///
  /// A getter, not a `static final`: the birth-year wheel's range is relative
  /// to today, and a list frozen at first access would drift as the year
  /// turned over in a long-lived process. Callers that rebuild per frame hold
  /// the result once — see [KycController.questions].
  static List<KycQuestion> get all => allFor(DateTime.now().year);

  /// The ages the questionnaire accepts. The frame shows years rather than
  /// ages now, so these are what bound the wheel rather than what it prints.
  static const int minAge = 18;
  static const int maxAge = 50;

  /// The youngest birth year the wheel offers. Below [minAge] on purpose, so
  /// the restriction can be shown rather than merely enforced by absence.
  static const int youngestOffered = 13;

  /// Where the wheel opens — the age `259:27860` prints in its readout.
  ///
  /// It must sit on an accepted age. The picker used to open on the third
  /// option, which was 20 while the list started at 18; once the list was
  /// extended down to [youngestOffered] that same position became 15, so the
  /// screen greeted everyone with the under-18 refusal.
  static const int defaultAge = 20;

  /// Whether this birth year puts the user under [minAge].
  static bool isUnderage(String birthYear, int currentYear) =>
      ageFor(birthYear, currentYear) < minAge;

  /// What the app says when someone picks a year that makes them too young.
  static const String underageMessage =
      'You need to be 18 or older to use Soothify. Please check the year '
      'you selected.';

  /// The age a birth year implies, as the left half of `259:27860` prints it.
  ///
  /// Birthday-agnostic — the question only ever collects a year, so this is
  /// the age reached during [currentYear], which is the most the year alone
  /// can support.
  static int ageFor(String birthYear, int currentYear) =>
      currentYear - (int.tryParse(birthYear) ?? currentYear);
}
