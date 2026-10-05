import 'package:get/get.dart';

import '../controller/trial_offer_controller.dart';

class TrialOfferBinding extends Bindings {
  @override
  void dependencies() {
    // Shared by the pop-up and the payment screen, so a plan chosen on one is
    // the plan the other charges for.
    Get.lazyPut(TrialOfferController.new, fenix: true);
  }
}
