import 'package:get/get.dart';

import '../../../../data/repositories/billing_repository.dart';
import '../controller/trial_offer_controller.dart';

class TrialOfferBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TrialOfferController(Get.find<BillingRepository>()));
  }
}
