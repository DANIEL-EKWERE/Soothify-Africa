import 'package:get/get.dart';

import '../../../../data/models/wellness_kyc.dart';
import '../controller/wellness_kyc_controller.dart';

class WellnessKycBinding extends Bindings {
  @override
  void dependencies() {
    final track = Get.arguments is WellnessTrack
        ? Get.arguments as WellnessTrack
        : WellnessTrack.meditation;
    Get.lazyPut(() => WellnessKycController(track));
  }
}
