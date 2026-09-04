import 'package:get/get.dart';

import '../../../../data/repositories/mood_repository.dart';
import '../controller/mood_checker_controller.dart';

class MoodCheckerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MoodCheckerController(Get.find<MoodRepository>()));
  }
}
