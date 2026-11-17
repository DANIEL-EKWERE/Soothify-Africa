import 'package:get/get.dart';

import '../../../../data/repositories/billing_repository.dart';
import '../../../../data/repositories/spaces_repository.dart';
import '../controller/passport_controller.dart';
import '../controller/passport_hub_controller.dart';

class PassportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PassportController(Get.find<BillingRepository>()));
    Get.lazyPut(
      () => PassportHubController(
        Get.find<BillingRepository>(),
        Get.find<SpacesRepository>(),
      ),
    );
  }
}
