/// The three environments the AI Hub offers — Figma "AI Hub | Unexpanded"
/// (page 124:2, `176:56425`).
enum EnvironmentVibe {
  sunsetCalm('sunset_calm', 'Sunset Calm'),
  morningMist('morning_mist', 'Morning Mist'),
  eveningBreeze('evening_breeze', 'Evening Breeze');

  const EnvironmentVibe(this.key, this.label);

  /// Persisted and sent to the API; never displayed.
  final String key;

  final String label;
}

/// One line in the Wellness Guide conversation.
class GuideMessage {
  const GuideMessage({required this.text, required this.fromGuide});

  final String text;

  /// Guide lines sit left in white; the user's sit right in blue.
  final bool fromGuide;
}
