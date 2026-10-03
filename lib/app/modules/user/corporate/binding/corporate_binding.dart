import 'package:get/get.dart';

import '../controller/corporate_controller.dart';

class CorporateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(CorporateController.new);
  }
}
