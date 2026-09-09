import 'package:get/get.dart';

import '../controller/ai_hub_controller.dart';

class AiHubBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(AiHubController.new);
  }
}
