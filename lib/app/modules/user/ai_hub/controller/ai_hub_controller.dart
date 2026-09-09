import '../../../../core/app_export.dart';
import '../../../../data/models/environment_vibe.dart';

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

  /// The two readouts beside the vibe. The frame prints "4.7mm" and "94.2%";
  /// they are a live session's telemetry, and there is no breathing engine
  /// behind them yet, so they are held here rather than invented per vibe.
  String get breathingPace => '4.7mm';
  String get easeLevel => '94.2%';

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

  void selectVibe(EnvironmentVibe value) => vibe.value = value;

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
