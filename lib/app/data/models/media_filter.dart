/// The library filter sheets — Figma "Meditation/filter" (135:12427),
/// "More Filter Screen" (135:12573) and "meditation/Style filter screen"
/// (135:12833).
///
/// Balance draws the same three frames (135:19379, 135:19491, 135:20011) with
/// byte-identical contents, so one set of screens serves both libraries — the
/// same call [LibrarySection] already makes for the library itself.
library;

/// Which sheet is on screen.
///
/// "Approach" was a fifth: it was in the menu and the design never drew its
/// options, so it opened an empty sheet. [teacher] has its own entry now,
/// because it is the practitioners the server knows.
enum FilterKind { duration, more, style, teacher }

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
  // No fallback, deliberately. The frame listed seven names -- Alex
  // Artymiak, Ali Owens, Rita, Annie, Chelsey Korus, Westernman, Mark Owen
  // -- and not one of them practises here, so ticking one filtered by a
  // person who does not exist. With no server to ask, the sheet says it has
  // nobody rather than offering strangers.
  teacher('Teacher', []),
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

  const FilterGroup(this.label, this.fallbackOptions);

  final String label;

  /// The design's own lists, kept only for the build with no server and for
  /// the goldens. The live options come from `/content/filters/` -- which is
  /// the point: this sheet used to offer seven teachers who were not
  /// practitioners here, and every group but duration narrowed nothing
  /// because no content carried any of it.
  final List<String> fallbackOptions;

  /// What this sheet offers now. Set once from the server; falls back to the
  /// design's list until it answers.
  List<FilterOption> get options =>
      FilterCatalogue.instance.optionsFor(this).isNotEmpty
          ? FilterCatalogue.instance.optionsFor(this)
          : [for (final label in fallbackOptions) FilterOption(label, label)];

  /// The four groups the More Filters frame stacks, in its own order.
  /// Teacher has moved to a sheet of its own.
  static const more = [focus, bodyPart, prop, music];
}

/// One tickable option: what the user reads, and what the server matches on.
///
/// The two are not the same any more. A chip says "Core" and the query
/// carries `focus-core`; a teacher chip says their name and carries their
/// id. The app used to send the label, which nothing could match.
class FilterOption {
  const FilterOption(this.value, this.label, {this.description = ''});

  /// What goes to the server — a tag slug, a practitioner id, or for
  /// durations the number of minutes.
  final String value;

  final String label;

  /// Only the Style sheet draws one.
  final String description;

  @override
  bool operator ==(Object other) =>
      other is FilterOption && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// What the filter sheets offer, as the server says.
///
/// A singleton because the sheets are drawn deep inside four different
/// screens and the list is one request for the whole app. Empty until
/// [load] has answered, and then the sheets fill themselves.
class FilterCatalogue {
  FilterCatalogue._();

  static final FilterCatalogue instance = FilterCatalogue._();

  final Map<FilterGroup, List<FilterOption>> _byGroup = {};

  List<int> durations = const [];

  List<FilterOption> optionsFor(FilterGroup group) =>
      _byGroup[group] ?? const [];

  bool get isLoaded => _byGroup.isNotEmpty;

  /// Replaces what the sheets offer. Called once, from the catalogue
  /// repository.
  void adopt({
    required Map<FilterGroup, List<FilterOption>> groups,
    List<int> durationBuckets = const [],
  }) {
    _byGroup
      ..clear()
      ..addAll(groups);
    if (durationBuckets.isNotEmpty) durations = durationBuckets;
  }

  /// For tests, which must not inherit another test's catalogue.
  void reset() {
    _byGroup.clear();
    durations = const [];
  }
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

/// What the user has ticked, across all the sheets.
///
/// Mutable and copied rather than rebuilt: a sheet edits a working copy and
/// only hands it back on Apply, so backing out of a sheet leaves the
/// library's applied filters untouched.
///
/// Holds each option's **value** -- a tag slug, a practitioner id, a number
/// of minutes -- not the label it is drawn with. The label is looked up for
/// display. It used to hold the labels, which is one reason nothing could be
/// matched against them.
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

  /// Every ticked option's label, in group order — the summary line a
  /// filtered library shows above its shelves.
  List<String> get labels => [
        for (final g in FilterGroup.values)
          for (final value in of(g)) _labelFor(g, value),
      ];

  String _labelFor(FilterGroup group, String value) {
    for (final option in group.options) {
      if (option.value == value) return option.label;
    }
    // A value whose option has since been retired server-side. Shown as
    // itself rather than dropped, so the count and the summary agree.
    return value;
  }

  /// The query the server filters on.
  ///
  /// Tags from every group go in one `tags=` list -- the server groups them
  /// itself and knows that two in the same group mean "either". Teacher and
  /// duration are their own parameters, because neither is a tag: one is the
  /// practitioner content is credited to, the other arithmetic on its
  /// length.
  Map<String, String> get queryParams {
    final tags = <String>[
      for (final group in FilterGroup.values)
        if (group != FilterGroup.duration && group != FilterGroup.teacher)
          ...of(group),
    ];

    return {
      if (tags.isNotEmpty) 'tags': tags.join(','),
      // One at a time: the sheet is a list of people, and content has one
      // practitioner, so two would always answer with nothing.
      if (of(FilterGroup.teacher).isNotEmpty)
        'teacher': of(FilterGroup.teacher).first,
      if (of(FilterGroup.duration).isNotEmpty)
        'duration': of(FilterGroup.duration)
            .map((v) => v.replaceAll(RegExp(r'[^0-9]'), ''))
            .where((v) => v.isNotEmpty)
            .join(','),
    };
  }

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
        .map((o) => int.tryParse(o.value.replaceAll(RegExp(r'[^0-9]'), '')))
        .whereType<int>()
        .toList();
    if (buckets.isEmpty) return true;
    final nearest = buckets.reduce(
      (a, b) => (a - minutes).abs() <= (b - minutes).abs() ? a : b,
    );
    // Values, not labels: a chip reads "10 minutes" and carries "10".
    return chosen.any(
      (v) => int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) == nearest,
    );
  }
}
