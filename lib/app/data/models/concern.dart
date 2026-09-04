/// What a user says brings them to Soothify, asked during onboarding.
///
/// Multi-select — the design's subtitle says "You can select more than one
/// option".
enum Concern {
  stress('stress', 'Stress'),
  anxiety('anxiety', 'Anxiety'),
  sleepDisorder('sleep_disorder', 'Sleep disorder'),
  depression('depression', 'Depression');

  const Concern(this.key, this.label);

  /// Persisted and sent to the API; never displayed.
  final String key;

  /// Shown in the option row.
  final String label;

  String get assetPath => 'assets/images/concerns/$key.png';

  static Concern? fromKey(String? key) {
    if (key == null) return null;
    for (final c in Concern.values) {
      if (c.key == key) return c;
    }
    return null;
  }
}
