import '../../../../core/app_export.dart';
import '../../../../data/models/environment_vibe.dart';
import '../widgets/breathing_scene.dart';

/// Backs the AI Hub — Figma "AI Hub | Unexpanded" (`176:56425`) and
/// "AI Hub | Expanded | Chat" (`176:56395`).
///
/// One screen, two states rather than two routes: the frames are the same
/// scene, and the copy on the first ("Tap Droplet or Chat to Expand") says the
/// second is an expansion of it.
class AiHubController extends GetxController {
  final RxBool expanded = false.obs;

  /// Whether the scene is breathing. The frame draws a pause control, so it
  /// starts running.
  final RxBool playing = true.obs;

  final Rx<EnvironmentVibe> vibe = EnvironmentVibe.morningMist.obs;

  /// One breath, and the pace that follows from it.
  ///
  /// The frame prints "4.7mm" and "94.2%" as fixed strings. Both now read
  /// what is actually happening: the pace is the droplet's own cycle, so the
  /// number and the thing it describes cannot disagree, and the ease level
  /// settles upward as breaths are taken.
  static const Duration breathPeriod = BreathingSceneLoop.defaultPeriod;

  String get breathingPace =>
      '${(60000 / breathPeriod.inMilliseconds).toStringAsFixed(1)}/min';

  /// Where the ease level starts, and what it approaches without reaching.
  static const double easeFloor = 82.0;
  static const double easeCeiling = 97.5;

  final RxDouble ease = easeFloor.obs;

  String get easeLevel => '${ease.value.toStringAsFixed(1)}%';

  /// Called once per completed breath by the scene. A settling curve, not a
  /// progress bar: each breath closes a twelfth of what is left.
  void countBreath() => ease.value += (easeCeiling - ease.value) / 12;

  /// The guide's opening lines, as the frame writes them. The frame then
  /// repeats one line as filler for the remaining bubbles; that is mock copy,
  /// not script, so it is not reproduced.
  final RxList<GuideMessage> messages = <GuideMessage>[
    const GuideMessage(
      text: 'Welcome to the gentle space.\nTake a moment to settle in',
      fromGuide: true,
    ),
    const GuideMessage(
      text: 'Notice the floating droplet. Try breathing in sync with its '
          'gentle bobbing.',
      fromGuide: true,
    ),
  ].obs;

  /// Changing the scene restarts the reading — the previous vibe's settling
  /// is not this one's.
  void selectVibe(EnvironmentVibe value) {
    if (vibe.value == value) return;
    vibe.value = value;
    ease.value = easeFloor;
  }

  void togglePlaying() => playing.value = !playing.value;

  void expand() => expanded.value = true;

  void collapse() => expanded.value = false;

  /// Starts the session. Nothing drives the breathing yet, so this only makes
  /// sure the scene is running and opens the guide.
  void breatheTogether() {
    playing.value = true;
    expand();
  }

  void send(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    messages.add(GuideMessage(text: trimmed, fromGuide: false));
    // No model behind this yet. Saying so beats a canned reply that looks
    // like the guide answered.
    AppFeedback.info('The wellness guide is not connected yet.');
  }
}
