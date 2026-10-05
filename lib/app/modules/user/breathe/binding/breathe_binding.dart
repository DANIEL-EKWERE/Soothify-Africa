import 'package:get/get.dart';

import '../controller/breathe_controller.dart';

class BreatheBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(BreatheController.new);
  }
}
