import 'package:get/get.dart';

import '../../../../core/app_export.dart';

/// Drives the client's side of joining a booked session — Figma `280:26643`.
///
/// The practitioner has its own screen and controller; this one shows the
/// *expert's* details rather than the client's, and its Cancel is outlined
/// rather than filled.
class ClientJoiningController extends GetxController {
  ClientJoiningController({
    this.expertName = 'Baraqhat',
    this.service = '1-on-1 Therapy',
    this.time = '10:00 AM - 11:00 AM',
    this.date = 'Sep 28 2026',
  });

  final String expertName;
  final String service;
  final String time;
  final String date;

  final RxBool micOn = true.obs;
  final RxBool cameraOn = true.obs;

  void toggleMic() => micOn.value = !micOn.value;

  void toggleCamera() => cameraOn.value = !cameraOn.value;

  void cancel() => Get.back();
}
