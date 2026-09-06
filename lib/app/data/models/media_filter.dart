/// The library filter sheets — Figma "Meditation/filter" (135:12427),
/// "More Filter Screen" (135:12573) and "meditation/Style filter screen"
/// (135:12833).
///
/// Balance draws the same three frames (135:19379, 135:19491, 135:20011) with
/// byte-identical contents, so one set of screens serves both libraries — the
/// same call [LibrarySection] already makes for the library itself.
library;

/// Which of the three sheets is on screen.
enum FilterKind { duration, more, style }

/// One group of chips. The order here is the order the frames draw them, and
/// [options] is in the frames' reading order (left column, then right).
enum FilterGroup {
  duration('Duration', [
    '5 minutes',
    '10 minutes',
    '15 minutes',
    '20 minutes',
    '30 minutes',
    '40 minutes',
    '50 minutes',
  ]),
  teacher('Teacher', [
    'Alex Artymiak',
    'Ali Owens',
    'Rita',
    'Annie',
    'Chelsey Korus',
    'Westernman',
    'Mark Owen',
  ]),
  // "Strenght" in the file; corrected here. Shipping a designer's typo in
  // product copy is a bug, not fidelity.
  focus('Focus', [
    'Morning',
    'Evening + Sleep',
    'Core',
    'Strength',
    'Stretch + Release',
    'Calm',
    'Basics',
    'Prenatal',
    'Postnatal',
    'Back Care',
    'Energy Balance',
    'Breath',
    'Inversion + Arm Balance',
  ]),
  // "Immune Sysytem" in the file; corrected here.
  bodyPart('Body parts', [
    'Arm',
    'Shoulder',
    'Knees',
    'Low Back',
    'Immune System',
    'Upper Back',
    'Legs',
  ]),
  // "Small  Stability Ball" in the file — a doubled space; collapsed here.
  prop('Prop', [
    'No Props',
    'Chair',
    'Wall Space',
    'Backless Chair',
    'Magic Circle',
    'Eye Pillow',
    'Small Stability Ball',
  ]),
  music('Music', ['Music', 'No Music']),
  style('Style', []);

  const FilterGroup(this.label, this.options);

  final String label;
  final List<String> options;

  /// The five groups the More Filters frame stacks, in its own order.
  static const more = [teacher, focus, bodyPart, prop, music];
}

/// A card on the Style sheet — a title over a one-line description.
class FilterStyle {
  const FilterStyle(this.title, this.description);

  final String title;
  final String description;

  /// In the frame's reading order: left column then right, row by row.
  static const all = [
    FilterStyle(
      'Mindfulness',
      'Paying attention to the present moment without judging it',
    ),
    FilterStyle(
      'Focused',
      'Concentrating on one thing, word or phrase to relax deeply',
    ),
    FilterStyle(
      'Transcendental',
      'Silently repeating a word or phrase to relax deeply',
    ),
    FilterStyle(
      'Box Breathing',
      'Breathing in, holding, breathing out, and holding again for the '
          'same amount of time',
    ),
    FilterStyle(
      'Reflection',
      'Thinking deeply about a specific idea or question',
    ),
    FilterStyle(
      'Walking',
      'Walking slowly and noticing each step and how your body feels',
    ),
    FilterStyle(
      'Breathwork',
      'Doing special breathing exercises to feel better and think clearly',
    ),
  ];
}

/// What the user has ticked, across all three sheets.
///
/// Mutable and copied rather than rebuilt: a sheet edits a working copy and
/// only hands it back on Apply, so backing out of a sheet leaves the library's
/// applied filters untouched.
class FilterSelection {
  FilterSelection([Map<FilterGroup, Set<String>>? initial])
    : _byGroup = {
        for (final g in FilterGroup.values) g: {...?initial?[g]},
      };

  final Map<FilterGroup, Set<String>> _byGroup;

  Set<String> of(FilterGroup group) => _byGroup[group]!;

  bool isSelected(FilterGroup group, String option) =>
      _byGroup[group]!.contains(option);

  void toggle(FilterGroup group, String option) {
    final set = _byGroup[group]!;
    set.contains(option) ? set.remove(option) : set.add(option);
  }

  void clear() {
    for (final set in _byGroup.values) {
      set.clear();
    }
  }

  /// How many options are ticked in total — the count on the library's filter
  /// glyph, and what decides whether Apply is live.
  int get count => _byGroup.values.fold(0, (sum, set) => sum + set.length);

  bool get isEmpty => count == 0;

  FilterSelection copy() => FilterSelection(_byGroup);

  /// Every ticked option, in group order — the summary line a filtered
  /// library shows above its shelves.
  List<String> get labels => [for (final g in FilterGroup.values) ...of(g)];

  /// Durations are the one group the mock data can actually answer, so it is
  /// the one that narrows a shelf. Everything else is recorded and passed to
  /// the API once there is one.
  ///
  /// A chip is a bucket, not an exact length: a 12-minute session belongs to
  /// "10 minutes" because that is the nearest chip. Matching exactly would
  /// leave most of the catalogue unreachable by any chip.
  bool matchesDuration(int seconds) {
    final chosen = of(FilterGroup.duration);
    if (chosen.isEmpty) return true;
    final minutes = seconds / 60;
    final buckets = FilterGroup.duration.options
        .map((l) => int.parse(l.split(' ').first))
        .toList();
    final nearest = buckets.reduce(
      (a, b) => (a - minutes).abs() <= (b - minutes).abs() ? a : b,
    );
    return chosen.contains('$nearest minutes');
  }
}
