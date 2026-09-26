import '../../../../core/app_export.dart';
import '../../../../data/models/expert_session.dart';

/// Backs the expert's pre-call screen — Figma "Joining session"
/// (`259:59996`).
class JoiningSessionController extends GetxController {
  /// [session] is injectable so a test can supply one; the route leaves it
  /// out and it comes from the arguments.
  JoiningSessionController({ExpertSession? session})
      : session = session ??
            (Get.arguments is ExpertSession
                ? Get.arguments as ExpertSession
                : null);

  final ExpertSession? session;

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
