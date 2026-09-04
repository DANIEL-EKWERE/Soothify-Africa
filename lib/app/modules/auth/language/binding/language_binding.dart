import 'package:get/get.dart';

import '../../../../data/services/language_service.dart';
import '../controller/language_controller.dart';

class LanguageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LanguageController(Get.find<LanguageService>()));
  }
}
