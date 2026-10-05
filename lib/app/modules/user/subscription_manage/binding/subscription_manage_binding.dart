import 'package:get/get.dart';

import '../controller/subscription_manage_controller.dart';

class SubscriptionManageBinding extends Bindings {
  @override
  void dependencies() {
    // Shared across the three screens, so a plan chosen on one is the plan
    // the next one shows.
    Get.lazyPut(SubscriptionManageController.new, fenix: true);
  }
}
