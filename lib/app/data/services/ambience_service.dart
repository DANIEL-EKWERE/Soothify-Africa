import 'dart:async';

import 'package:flutter/animation.dart' show Curves;
import 'package:just_audio/just_audio.dart';

import '../../core/app_export.dart';
import '../../modules/auth/splash/splash_timing.dart';

/// The stream that fades up under the splash's breathing prompts.
///
/// A [GetxService], not something the splash owns: the sound starts on the
/// splash and ends several seconds *after* it has handed over, so a player
/// living on that widget would be disposed mid-fade.
///
/// The shape, in the order it happens:
///
/// ```
///   t=0.0s   splash shows the wordmark            (silent)
///   t=3.0s   the wordmark starts leaving          start(), fade up begins
///   t=6.8s   "Inhale Deeply" is fully lit         at full volume
///   t=13.8s  the splash hands over                land() is called
///   t=16.8s  three seconds on the new screen      fade down begins
///   t=19.3s  silence                              released
/// ```
///
/// Those times are derived from [SplashTiming]'s own constants rather than
/// written down again, so retiming the prompts retimes the sound with them.
///
/// Every failure is swallowed. A device with no audio, a codec that will not
/// open, a file that went missing from the bundle — none of that is worth
/// holding up the first screen of the app for, and none of it is worth an
/// error in front of a user who came here to calm down.
class AmbienceService extends GetxService {
  AmbienceService({AudioPlayer? player, bool enabled = true})
      : _player = player,
        _enabled = enabled;

  /// Injected by the tests. Live, one is made on first use and thrown away
  /// after the fade — holding an idle player open for the whole session to
  /// save 18 seconds of setup is not a trade worth making.
  AudioPlayer? _player;

  /// False in a widget test, where there is no audio platform at all.
  final bool _enabled;

  static const asset = 'assets/audio/splash_ambience.mp3';

  /// How loud it gets. Well under the media player's own level: this is
  /// meant to be noticed rather than listened to, and it arrives unasked.
  static const peak = 0.45;

  /// The fade up runs for exactly one word-swap, so the stream arrives at
  /// full in the same moment "Inhale Deeply" finishes arriving.
  static Duration get fadeIn => SplashTiming.fade;

  /// How long it keeps playing once the splash has handed over.
  static const hold = Duration(seconds: 3);

  /// And how long it takes to leave. Longer than it needs to be, because a
  /// quick cut off is the one thing that would make it feel abrupt.
  static const fadeOut = Duration(milliseconds: 2500);

  /// How often the volume is nudged during a fade. 40ms is 25 steps a
  /// second — smooth to the ear, and cheap enough to run beside the
  /// splash's own animation without competing with it.
  static const _step = Duration(milliseconds: 40);

  Timer? _fade;
  Timer? _holdTimer;
  bool _started = false;
  bool _finished = false;

  /// Whether a fade is currently running. For the tests.
  bool get isFading => _fade?.isActive ?? false;

  /// The volume as last set, so a test can watch the shape of the fade.
  double get volume => _volume;
  double _volume = 0;

  /// Start the stream, silent, and bring it up over [fadeIn].
  ///
  /// Called once, as the splash leaves the wordmark. Calling it again does
  /// nothing: a hot reload or a second splash must not stack two players.
  Future<void> start() async {
    if (!_enabled || _started) return;
    _started = true;

    try {
      final player = _player ??= AudioPlayer();
      await player.setAsset(asset);
      // Looped, as insurance rather than as intent. The clip is cut long
      // enough for the whole sequence, but a slow cold start can push the
      // handoff out, and silence arriving before the fade does would be
      // more noticeable than a seam in running water.
      await player.setLoopMode(LoopMode.all);
      await player.setVolume(0);
      _volume = 0;
      await player.play();
      _fadeTo(peak, fadeIn);
    } catch (error, stack) {
      // Nothing to recover: there is simply no sound this launch.
      Log.e('splash ambience could not start', error: error, stackTrace: stack);
      _started = false;
      await _release();
    }
  }

  /// The splash has handed over. Hold for [hold], then fade out and release.
  ///
  /// Called on every handoff, whatever the splash landed on — the home
  /// shell, the intro carousel on a first launch, the questionnaire, a
  /// studio's portal. Tying it to one destination would leave the sound
  /// hanging on all the others.
  void land() {
    if (!_enabled || _finished) return;
    _finished = true;
    _holdTimer?.cancel();
    _holdTimer = Timer(hold, () => _fadeTo(0, fadeOut, release: true));
  }

  /// Stop now, with no fade. For signing out, or anything else that wants
  /// the app quiet immediately.
  Future<void> stop() async {
    _finished = true;
    await _release();
  }

  /// Walk the volume to [target] over [over], then optionally let go.
  void _fadeTo(double target, Duration over, {bool release = false}) {
    _fade?.cancel();

    final from = _volume;
    final steps = (over.inMilliseconds / _step.inMilliseconds).ceil();
    if (steps <= 0) {
      _set(target);
      if (release) unawaited(_release());
      return;
    }

    var done = 0;
    _fade = Timer.periodic(_step, (timer) {
      done++;
      // Eased rather than linear. A linear ramp is heard as a sudden
      // arrival at the top and a sudden departure at the bottom, because
      // loudness is not linear in amplitude.
      final progress = Curves.easeInOut.transform((done / steps).clamp(0, 1));
      _set(from + (target - from) * progress);

      if (done >= steps) {
        timer.cancel();
        if (release) unawaited(_release());
      }
    });
  }

  void _set(double value) {
    _volume = value.clamp(0, 1);
    // Not awaited: this runs 25 times a second and a dropped frame of
    // volume is inaudible, while awaiting it inside a periodic timer would
    // let the calls pile up behind each other.
    unawaited(_player?.setVolume(_volume).catchError((_) {}));
  }

  Future<void> _release() async {
    _fade?.cancel();
    _holdTimer?.cancel();
    final player = _player;
    _player = null;
    if (player == null) return;
    try {
      await player.stop();
      await player.dispose();
    } catch (error) {
      Log.e('splash ambience would not let go', error: error);
    }
  }

  @override
  void onClose() {
    unawaited(_release());
    super.onClose();
  }
}
