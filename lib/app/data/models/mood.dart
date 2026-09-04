/// The nine moods offered on the Mood Checker screen, in the order the design
/// lays them out (three rows of three).
enum Mood {
  calm('calm', 'Calm'),
  happy('happy', 'Happy'),
  angry('angry', 'Angry'),
  weak('weak', 'Weak'),
  fearful('fearful', 'Fearful'),
  sad('sad', 'Sad'),
  anxious('anxious', 'Anxious'),
  stress('stress', 'Stress'),
  depress('depress', 'Depress');

  const Mood(this.key, this.label);

  /// Stable identifier — what gets persisted and sent to the API. Never
  /// display this; it must stay constant even if the label is reworded.
  final String key;

  /// Shown under the tile.
  final String label;

  String get assetPath => 'assets/images/moods/$key.png';

  static Mood? fromKey(String? key) {
    if (key == null) return null;
    for (final m in Mood.values) {
      if (m.key == key) return m;
    }
    return null;
  }
}

/// One recorded mood check-in.
class MoodEntry {
  const MoodEntry({
    required this.id,
    required this.mood,
    required this.recordedAt,
    this.note = '',
  });

  final String id;
  final Mood mood;
  final DateTime recordedAt;
  final String note;

  /// Keys are snake_case to match what DRF will serve.
  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        id: '${json['id']}',
        mood: Mood.fromKey(json['mood'] as String?) ?? Mood.calm,
        recordedAt:
            DateTime.tryParse('${json['recorded_at']}')?.toLocal() ??
                DateTime.now(),
        note: json['note'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'mood': mood.key,
        'recorded_at': recordedAt.toUtc().toIso8601String(),
        'note': note,
      };
}
