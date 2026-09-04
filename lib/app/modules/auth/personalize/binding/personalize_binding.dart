import 'package:get/get.dart';

import '../controller/personalize_controller.dart';

class PersonalizeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PersonalizeController());
  }
}
