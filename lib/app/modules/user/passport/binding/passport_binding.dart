import 'package:get/get.dart';

import '../../../../data/repositories/billing_repository.dart';
import '../controller/passport_controller.dart';

class PassportBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(
        () => PassportController(Get.find<BillingRepository>()),
      );
}
