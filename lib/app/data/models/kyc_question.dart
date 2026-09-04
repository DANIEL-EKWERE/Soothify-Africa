/// How a question's answers behave.
enum KycInput {
  /// Any number of options; Next unlocks once one is chosen.
  multi,

  /// Exactly one option.
  single,

  /// A scrolling wheel of values, always with something selected.
  wheel,
}

class KycOption {
  const KycOption(this.value, this.label, {this.assetPath});

  /// Persisted and sent to the API; never displayed.
  final String value;

  final String label;

  /// 30x30 icon shown at the head of the row, where the design has one.
  final String? assetPath;
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

  bool get isMulti => input == KycInput.multi;

  static const String _multiHint = 'You Can Select More Than One Option';

  static final List<KycQuestion> all = [
    const KycQuestion(
      id: 'concerns',
      prompt: 'What brings you to Soothify?',
      subtitle: _multiHint,
      input: KycInput.multi,
      options: [
        KycOption('stress', 'Stress',
            assetPath: 'assets/images/concerns/stress.png'),
        KycOption('anxiety', 'Anxiety',
            assetPath: 'assets/images/concerns/anxiety.png'),
        KycOption('sleep_disorder', 'Sleep disorder',
            assetPath: 'assets/images/concerns/sleep_disorder.png'),
        KycOption('depression', 'Depression',
            assetPath: 'assets/images/concerns/depression.png'),
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
