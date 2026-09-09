/// The Mood Checker is a slider, not a grid — Figma "Mood checker" on page
/// 124:2 (light `176:22410`-`176:22479`, dark `176:31360`-`176:31429`).
///
/// The user drags a single handle from "Awful" to "Awesome" and a character
/// illustration changes to match. Only the two ends are labelled in the
/// design; the steps in between are told entirely by the artwork.
library;

/// The four illustrations the slider moves through.
///
/// [label] is shown only in the check-in history, which needs a word for a
/// past entry. "Awful" and "Awesome" are the design's own; "Low" and "Good"
/// are ours, because the frames label nothing in between.
enum MoodLevel {
  awful('awful', 'Awful'),
  low('low', 'Low'),
  good('good', 'Good'),
  awesome('awesome', 'Awesome');

  const MoodLevel(this.key, this.label);

  /// Stable identifier — what gets persisted and sent to the API. Never
  /// display this; it must stay constant even if the label is reworded.
  final String key;

  final String label;

  /// Where each illustration takes over, read off the handle positions in the
  /// frames: the artwork changed at roughly 20%, 45% and 70% of the track,
  /// not at even quarters.
  static const _thresholds = [0.20, 0.45, 0.70];

  static MoodLevel forScore(double score) {
    final s = score.clamp(0.0, 1.0);
    for (var i = 0; i < _thresholds.length; i++) {
      if (s < _thresholds[i]) return MoodLevel.values[i];
    }
    return MoodLevel.awesome;
  }

  /// The middle of this level's band — where the handle sits when a saved
  /// entry is reopened and only the level survived.
  double get representativeScore => switch (this) {
        MoodLevel.awful => 0.10,
        MoodLevel.low => 0.32,
        MoodLevel.good => 0.57,
        MoodLevel.awesome => 0.85,
      };

  static MoodLevel? fromKey(String? key) {
    if (key == null) return null;
    for (final l in MoodLevel.values) {
      if (l.key == key) return l;
    }
    return null;
  }
}

/// Which character is drawn. Taken from the KYC "What is your gender?"
/// answer, so the figure on screen is the user's own.
enum MoodFigure {
  female('female'),
  male('male');

  const MoodFigure(this.key);

  final String key;

  /// Anything that is not an explicit "male" — non-binary, undisclosed, or a
  /// guest who never answered — gets the female set. It is the only one the
  /// design draws all four steps for; the male frames reuse one illustration
  /// for the top two.
  static MoodFigure fromKycAnswer(String? answer) =>
      answer == 'male' ? MoodFigure.male : MoodFigure.female;

  String artFor(MoodLevel level) {
    // The male set has no distinct "awesome" — the design's two right-hand
    // frames are the same illustration.
    final step = (this == MoodFigure.male && level == MoodLevel.awesome)
        ? MoodLevel.good
        : level;
    return 'assets/images/mood/${key}_${step.key}.png';
  }

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

  /// The nine old moods, placed on the new scale. Approximate by nature —
  /// there is no true mapping from "Fearful" to a number — but it keeps a
  /// user's streak and calendar intact instead of dropping their history.
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
