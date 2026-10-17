import 'package:get/get.dart';

import '../../../../data/repositories/corporate_repository.dart';
import '../controller/corporate_controller.dart';

class CorporateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CorporateController(Get.find<CorporateRepository>()));
  }
}
