import 'package:get/get.dart';

import '../controller/spaces_controller.dart';

class SpacesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(SpacesController.new);
  }
}
