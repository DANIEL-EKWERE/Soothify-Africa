import '../../core/utils/image_constant.dart';

/// How a session is taken — Figma `259:38702`, "How do you want to have
/// your sessions?"
///
/// The design asks this inside the therapy questionnaire and nowhere else,
/// and the answer was kept on that controller and thrown away. Every
/// session was therefore booked as a video call, whatever anybody chose,
/// and the other two disciplines were never asked at all.
enum SessionMode {
  /// The server's value is `phone`, not `audio`. The label is the
  /// design's: "camera off" is the part people are actually choosing.
  audio('phone', 'Audio only (camera off)', ImageConstant.icPhoneCall),

  video('video', 'Video call', ImageConstant.icVideoCall);

  const SessionMode(this.wire, this.label, this.icon);

  /// What the API stores. See Session.MODES server-side.
  final String wire;

  /// What the card says — "Phone call" / "Video call", as the Schedule
  /// frame draws them. Shorter than [label], which spells out what the
  /// questionnaire means by it.
  String get cardLabel =>
      this == SessionMode.audio ? 'Phone call' : 'Video call';

  final String label;
  final String icon;

  /// A video call is the fuller thing and what the frames draw selected.
  static const fallback = SessionMode.video;

  static SessionMode fromWire(String? value) {
    for (final mode in SessionMode.values) {
      if (mode.wire == value) return mode;
    }
    return fallback;
  }

  /// What the questionnaire's option reads as. Matched on "audio" rather
  /// than the whole string so a reworded label does not silently stop
  /// mapping.
  static SessionMode fromAnswer(String? answer) =>
      (answer ?? '').toLowerCase().contains('audio')
          ? SessionMode.audio
          : SessionMode.video;
}
