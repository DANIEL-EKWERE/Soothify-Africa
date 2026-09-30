/// The Mood Checker is a slider, not a grid — Figma "Mood checker" on page
/// 124:2 (light `176:22410`-`176:22479`, dark `176:31360`-`176:31429`).
///
/// The user drags a single handle from "Awful" to "Awesome" and a character
/// illustration changes to match. Only the two ends are labelled in the
/// design; the steps in between are told entirely by the artwork.
library;

/// The ten moods the slider moves through — Figma "Mood checker" and the
/// `Recommendation | <mood>` frames on page 124:2.
///
/// It was four until 2026-09-26, with two of the names ours because the
/// frames only labelled the ends. The design now names all ten and writes a
/// line of copy for each, so none of this is invented any more.
enum MoodLevel {
  awful('awful', 'Awful',
      "Ah, today feels heavy. I'm really sorry you're dealing with this. "
      'Take it slow. Here are a few things that might help ease the weight '
      'a bit.'),
  drained('drained', 'Drained',
      "You're running on empty, huh? That's completely valid. Hit pause for "
      'a second and check out these gentle picks to help you recharge'),
  anxious('anxious', 'Anxious',
      'Brain moving a million miles an hour? Let’s take a deep breath '
      'together. Here are a few calming things to help quiet the noise'),
  low('low', 'Low',
      'Some days just feel a bit gray, and you don’t have to fake being '
      'okay. Sit with these for a little bit, no pressure at all'),
  // The frame's tab reads "Neutra" — a truncation, not a word.
  neutral('neutral', 'Neutral',
      'Just coasting through the middle today? Nothing wrong with that. '
      'Here are a few nice little things to match your vibe.'),
  reflective('reflective', 'Reflective',
      'In your head today, huh? Embrace it. Here are some thoughtful reads '
      'and sounds to keep you company while you think.'),
  content('content', 'Content',
      'Sitting pretty and at peace today? We love to see it. Here are a few '
      'cozy picks to keep your day flowing nicely.'),
  energized('energized', 'Energized',
      'Okay, look at you! Got that spark going today. Let’s channel that '
      'good energy into something fun.'),
  joyful('joyful', 'Joyful',
      "You're glowing today! It’s so good to see you feeling this good. "
      'Here are some great picks to ride this wave.'),
  awesome('awesome', 'Awesome',
      'Absolute top form today! Love that for you. Dive into these and keep '
      'the good energy rolling.');

  const MoodLevel(this.key, this.label, this.recommendationIntro);

  /// Stable identifier — what gets persisted and sent to the API. Never
  /// display this; it must stay constant even if the label is reworded.
  final String key;

  final String label;

  /// What the recommendation screen says above its picks, in the design's
  /// own words. Each mood gets its own; they are not interchangeable.
  final String recommendationIntro;

  /// Ten even bands across the track. The four-level scale had measured
  /// thresholds because the frames parked the handle in four places; with ten
  /// named stops an even split is what the slider can actually express.
  static MoodLevel forScore(double score) {
    final i = (score.clamp(0.0, 1.0) * values.length).floor();
    return values[i.clamp(0, values.length - 1)];
  }

  /// The middle of this level's band — where the handle sits when a saved
  /// entry is reopened.
  double get representativeScore =>
      (index + 0.5) / values.length;

  static MoodLevel? fromKey(String? key) {
    if (key == null) return null;
    for (final l in MoodLevel.values) {
      if (l.key == key) return l;
    }
    return null;
  }
}

/// Which character is drawn. Taken from the KYC "How do you identify?"
/// answer, so the figure on screen is the user's own.
enum MoodFigure {
  female('female'),
  male('male');

  const MoodFigure(this.key);

  final String key;

  /// Anything that is not an explicit "male" — non-binary, undisclosed, or a
  /// guest who never answered — gets the female set.
  static MoodFigure fromKycAnswer(String? answer) =>
      answer == 'male' ? MoodFigure.male : MoodFigure.female;

  /// Each mood has its own drawing, for both figures — twenty files in
  /// `assets/images/mood/`, named `<figure>_<mood>.png`.
  ///
  /// This used to route thirteen of the twenty through a nearest-neighbour
  /// map, because only four female and three male illustrations had been
  /// drawn. The full set landed; the map is gone.
  String artFor(MoodLevel level) =>
      'assets/images/mood/${key}_${level.key}.png';

  /// Every asset this figure can show, for precaching so dragging the slider
  /// never flashes an empty box.
  Iterable<String> get allArt =>
      MoodLevel.values.map(artFor).toSet();
}

/// One recorded mood check-in.
class MoodEntry {
  const MoodEntry({
    required this.id,
    required this.score,
    required this.recordedAt,
    this.note = '',
  });

  final String id;

  /// Where the slider sat, 0 (Awful) to 1 (Awesome). Stored as the raw
  /// position rather than the level so the scale can gain steps later without
  /// rewriting anyone's history.
  final double score;

  final DateTime recordedAt;
  final String note;

  MoodLevel get level => MoodLevel.forScore(score);

  /// Keys are snake_case to match what DRF will serve.
  ///
  /// Reads the old `mood` key too: before the slider this was one of nine
  /// named moods, and an upgrading user still has those entries on disk.
  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        id: '${json['id']}',
        score: (json['score'] as num?)?.toDouble() ??
            _legacyScore(json['mood'] as String?),
        recordedAt:
            DateTime.tryParse('${json['recorded_at']}')?.toLocal() ??
                DateTime.now(),
        note: json['note'] as String? ?? '',
      );

  /// The nine emoji moods that predate the slider, placed on the scale.
  /// Approximate by nature — there is no true mapping from "Fearful" to a
  /// number — but it keeps a user's streak and calendar intact instead of
  /// dropping their history.
  static double _legacyScore(String? mood) => switch (mood) {
        'happy' => 0.85,
        'calm' => 0.75,
        'weak' => 0.40,
        'sad' || 'depress' => 0.10,
        'angry' || 'stress' => 0.15,
        'anxious' || 'fearful' => 0.30,
        _ => 0.5,
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'score': score,
        'recorded_at': recordedAt.toUtc().toIso8601String(),
        'note': note,
      };
}
