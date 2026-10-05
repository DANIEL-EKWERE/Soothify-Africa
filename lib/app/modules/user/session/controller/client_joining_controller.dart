import '../../../../core/app_export.dart';
import '../../../../data/models/session_invite.dart';
import '../../../../data/models/session_offering.dart';
import '../../booking/controller/booking_controller.dart';

/// Drives the client's side of joining a booked session — Figma `280:26643`.
///
/// The practitioner has its own screen and controller; this one shows the
/// *expert's* details rather than the client's, and its Cancel is outlined
/// rather than filled.
class ClientJoiningController extends GetxController {
  ClientJoiningController({
    String? expertName,
    String? service,
    String? time,
    String? date,
    this.connecting = const Duration(seconds: 4),
  })  : _invite = Get.arguments is SessionInvite
            ? Get.arguments as SessionInvite
            : null,
        _expertName = expertName,
        _service = service,
        _time = time,
        _date = date;

  /// The session tapped in the feed, when the screen was opened from there.
  final SessionInvite? _invite;

  final String? _expertName;
  final String? _service;
  final String? _time;
  final String? _date;

  /// How long "Joining Call" holds before the call opens. The screen owns the
  /// countdown — it is what the user is waiting on — and this is injectable so
  /// a test does not sit through a real four seconds.
  final Duration connecting;

  String get expertName => _expertName ?? _invite?.expertName ?? 'Baraqhat';
  String get service => _service ?? _invite?.service ?? '1-on-1 Therapy';
  String get time => _time ?? _invite?.time ?? '10:00 AM - 11:00 AM';
  String get date => _date ?? _invite?.date ?? 'Sep 28 2026';

  final RxBool micOn = true.obs;
  final RxBool cameraOn = true.obs;

  void toggleMic() => micOn.value = !micOn.value;

  void toggleCamera() => cameraOn.value = !cameraOn.value;

  /// Into the call itself, replacing the waiting room so Cancel inside the
  /// call does not step back onto it.
  ///
  /// The camera toggle above is the choice between a voice call and a video
  /// one — the same bargain every pre-join screen offers. Nothing else in the
  /// flow asks: the communication picker the design draws sits on a branch
  /// that booking no longer takes.
  void join() {
    Get.offNamed(
      AppRoutes.booking,
      arguments: BookingEntry(
        offering: _invite?.offering ?? SessionOffering.therapy,
        stage: BookingStage.call,
        mode: cameraOn.value ? CallMode.video : CallMode.phone,
      ),
    );
  }

  void cancel() => Get.back();
}
