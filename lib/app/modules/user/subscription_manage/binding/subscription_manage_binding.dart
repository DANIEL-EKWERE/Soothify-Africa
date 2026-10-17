import 'package:get/get.dart';

import '../../../../data/repositories/billing_repository.dart';
import '../controller/subscription_manage_controller.dart';

class SubscriptionManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => SubscriptionManageController(Get.find<BillingRepository>()),
    );
  }
}
