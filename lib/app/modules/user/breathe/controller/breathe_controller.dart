import 'dart:async';

import '../../../../core/app_export.dart';
import '../../../../data/models/app_tab.dart';
import '../../../../data/models/checkin_kind.dart';
import '../../../../data/repositories/breathing_repository.dart';
import '../../../../data/repositories/local_breathing_repository.dart';
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
  BreatheController({this.total = 60, BreathingRepository? breathing})
      : _breathing = breathing ??
            (Get.isRegistered<BreathingRepository>()
                ? Get.find<BreathingRepository>()
                // A golden or a widget test reaches this screen without the
                // app's bindings. The device-only store needs no network and
                // no account, so the clock still runs.
                : LocalBreathingRepository());

  final BreathingRepository _breathing;

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
    _load();
  }

  /// The streak as it stands. The device answers first, so the number is
  /// right before any network call finishes; the account can only raise it,
  /// which is what makes a reinstall keep somebody's forty days.
  Future<void> _load() async {
    final state = await _breathing.state();
    streak.value = state.streak;
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
    streak.value = (await _breathing.recordMinute(seconds: total)).streak;
  }

  /// "Remind me daily" — the reminder screen, for this habit.
  ///
  /// The minute was reachable only by tapping a notification somebody else
  /// decided to send. This is where they decide instead: the same weekly
  /// reminder the other daily habits use, which the app re-arms at launch
  /// (see PushService.rearmSavedReminders) because Android drops alarms
  /// when an app is force-stopped.
  void scheduleIt() => Get.toNamed(
        AppRoutes.dailyReminder,
        arguments: CheckinKind.breathing,
      );

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
