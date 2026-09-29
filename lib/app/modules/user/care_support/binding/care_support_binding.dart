import 'package:get/get.dart';

import '../controller/care_support_controller.dart';

class CareSupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(CareSupportController.new);
  }
}
