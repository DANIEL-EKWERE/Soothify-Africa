import 'dart:async';

import '../../../../core/app_export.dart';
import '../../../../data/models/app_tab.dart';
import '../../shell/controller/shell_controller.dart';

/// Where the minute has got to — Figma draws each as its own frame.
enum BreathePhase { invitation, active, done }

/// One instruction in the breathing cycle.
enum BreatheCue {
  inhale('Breathe in slowly through your nose...', 4),
  hold('Hold it, gently...', 2),
  exhale('Breathe out slowly through your mouth...', 6);

  const BreatheCue(this.label, this.seconds);

  final String label;
  final int seconds;

  static int get cycleSeconds =>
      BreatheCue.values.fold(0, (sum, c) => sum + c.seconds);

  /// The cue a given number of seconds into a cycle, and how far through it.
  ///
  /// The screen needs this at a finer grain than the one-second clock: the
  /// circle has to grow and shrink smoothly across a cue, not step once a
  /// second.
  static (BreatheCue, double) at(double secondsIntoCycle) {
    var into = secondsIntoCycle % cycleSeconds;
    for (final c in BreatheCue.values) {
      if (into < c.seconds) return (c, into / c.seconds);
      into -= c.seconds;
    }
    return (BreatheCue.inhale, 0);
  }
}

/// Backs the 60-second breathing minute — Figma's "Push Notification"
/// section: `313:25770` (invitation), `313:25785` and its siblings (the
/// countdown) and `313:25825` (completion).
///
/// The three countdown frames differ only in the line under the clock. Those
/// variants could not be read — the render budget ran out after three frames
/// — so the cues below are a 4-2-6 cycle of this app's own, with the one line
/// the readable frame carries kept verbatim.
class BreatheController extends GetxController {
  BreatheController({this.total = 60});

  /// The minute the design asks for.
  final int total;

  final Rx<BreathePhase> phase = BreathePhase.invitation.obs;

  /// Seconds left. The frame shows 0:59, i.e. the first tick has passed.
  final RxInt remaining = 0.obs;

  Timer? _tick;

  /// How many days running, including today once the minute is finished.
  final RxInt streak = 0.obs;

  @override
  void onInit() {
    super.onInit();
    remaining.value = total;
    streak.value = PrefUtils().breatheStreak();
  }

  @override
  void onClose() {
    _tick?.cancel();
    super.onClose();
  }

  String get clock {
    final s = remaining.value;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  /// Which cue the current second falls under.
  BreatheCue get cue {
    final elapsed = total - remaining.value;
    var into = elapsed % BreatheCue.cycleSeconds;
    for (final c in BreatheCue.values) {
      if (into < c.seconds) return c;
      into -= c.seconds;
    }
    return BreatheCue.inhale;
  }

  /// 0..1 through the current cue, which is what the circle swells on.
  double get cuePhase {
    final elapsed = total - remaining.value;
    var into = elapsed % BreatheCue.cycleSeconds;
    for (final c in BreatheCue.values) {
      if (into < c.seconds) return into / c.seconds;
      into -= c.seconds;
    }
    return 0;
  }

  void start() {
    if (phase.value == BreathePhase.active) return;
    phase.value = BreathePhase.active;
    remaining.value = total;
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remaining.value <= 1) {
        _finish();
        return;
      }
      remaining.value -= 1;
    });
  }

  Future<void> _finish() async {
    _tick?.cancel();
    remaining.value = 0;
    phase.value = BreathePhase.done;
    streak.value = await PrefUtils().recordBreatheDay();
  }

  /// "Not right now" — leaves without starting anything.
  void decline() => Get.back();

  /// The × at the top. Stops the clock so it cannot keep running behind the
  /// screen that replaces this one.
  void close() {
    _tick?.cancel();
    Get.back();
  }

  void returnHome() => Get.until((route) => Get.currentRoute == AppRoutes.shell);

  void exploreClasses() {
    Get.until((route) => Get.currentRoute == AppRoutes.shell);
    if (Get.isRegistered<ShellController>()) {
      Get.find<ShellController>().current.value = AppTab.discovery;
    }
  }
}
