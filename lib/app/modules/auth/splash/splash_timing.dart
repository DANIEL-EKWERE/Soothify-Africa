/// How long each beat of the splash lasts.
///
/// Its own file so that things which are not the splash can be timed
/// against it. The stream that fades up under the breathing prompts has to
/// arrive exactly as the first word does, and the alternative — the audio
/// service importing the screen, which already imports the service — is a
/// cycle between a service and a widget.
///
/// [SplashScreen] re-exports every one of these, so the screen stays the
/// place you look for them.
abstract final class SplashTiming {
  /// How long the wordmark holds before the breathing prompts begin.
  static const brandHold = Duration(seconds: 3);

  /// How long the outgoing word takes to reach nothing at all, and the same
  /// again for the incoming one.
  ///
  /// 1.4s each way. 600 read as a UI transition and 1000 was still brisk
  /// for the one screen whose whole job is to slow you down.
  static const fadeOutMs = 1400;

  /// The empty beat between the two words — a second of nothing, so one has
  /// plainly gone before the next arrives.
  static const gapMs = 1000;

  /// One swap, start to finish: out, the gap, then in.
  static const fadeMs = fadeOutMs + gapMs + fadeOutMs;
  static const fade = Duration(milliseconds: fadeMs);

  /// How long a word stands fully lit, once it has finished arriving.
  static const litMs = 1600;

  /// How long each prompt stays up, measured from the moment it is swapped
  /// in — the swap itself, then [litMs] of stillness.
  ///
  /// Derived rather than written down: this was a literal 3800 alongside a
  /// comment claiming 1.6s of stillness, which stopped being true the moment
  /// the fade changed. Now it cannot drift.
  static const breathHold = Duration(milliseconds: fadeMs + litMs);

  /// The prompts, in order.
  static const prompts = ['Inhale Deeply', 'Exhale Slowly'];

  /// Everything after the wordmark: the whole breathing sequence.
  static const afterBrand = Duration(
    milliseconds: (fadeMs + litMs) * 2,
  );
}
