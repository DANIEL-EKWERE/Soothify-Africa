import '../../../../core/app_export.dart';
import '../../../../data/models/expert_session.dart';

/// Backs the expert's pre-call screen — Figma "Joining session"
/// (`259:59996`).
///
/// The frame draws no "Join", and this took that literally: the screen was
/// the joining, nothing advanced it, and a practitioner sat on a pulsing
/// circle for ever. It now opens the real call when it is time, and says
/// when it is not.
class JoiningSessionController extends GetxController {
  /// [session] is injectable so a test can supply one; the route leaves it
  /// out and it comes from the arguments.
  JoiningSessionController({ExpertSession? session, DateTime Function()? now})
      : session = session ??
            (Get.arguments is ExpertSession
                ? Get.arguments as ExpertSession
                : null),
        _now = now ?? DateTime.now;

  final ExpertSession? session;

  final DateTime Function() _now;

  /// How early the practitioner may go in. Earlier than the client, so
  /// they can be in the room waiting rather than arriving second.
  static const openFrom = Duration(minutes: 15);

  /// Whether the room may be entered yet.
  ///
  /// Unlike the client's screen this needs no lookup: the session the
  /// dashboard handed over carries its own hours.
  bool get canJoin {
    final booked = session;
    if (booked == null) return false;

    final now = _now();
    return !now.isBefore(booked.startsAt.subtract(openFrom)) &&
        now.isBefore(booked.endsAt);
  }

  /// Why it cannot be joined, for the line under the pulse.
  String get waitLabel {
    final booked = session;
    if (booked == null) return 'This session could not be found.';
    if (canJoin) return '';

    final now = _now();
    if (!now.isBefore(booked.endsAt)) return 'This session has ended.';

    final until = booked.startsAt.difference(now);
    if (until.inDays >= 1) {
      final days = until.inDays;
      return 'This session is in $days ${days == 1 ? 'day' : 'days'}.';
    }
    if (until.inHours >= 1) {
      final hours = until.inHours;
      return 'This session starts in $hours ${hours == 1 ? 'hour' : 'hours'}.';
    }
    return 'You can join fifteen minutes before it starts.';
  }

  /// Into the room. Nothing called this before -- there was nothing to
  /// call.
  Future<void> join() async {
    final booked = session;
    if (booked == null || !canJoin) return;

    await Get.toNamed(AppRoutes.sessionCall, arguments: booked.id);
    // However the call ended, this screen has done its job.
    Get.back();
  }

  /// The frame draws both controls in their resting state and gives no
  /// engaged one, so "on" is the starting point for each.
  final RxBool micOn = true.obs;
  final RxBool cameraOn = true.obs;

  void toggleMic() => micOn.toggle();

  void toggleCamera() => cameraOn.toggle();

  /// The frame's only action. There is no "Join" — the screen *is* the
  /// joining, and this backs out of it.
  void cancel() => Get.back();
}
