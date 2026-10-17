import 'package:get/get.dart';

import '../../../../data/repositories/spaces_repository.dart';
import '../controller/spaces_controller.dart';

class SpacesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SpacesController(Get.find<SpacesRepository>()));
  }
}
