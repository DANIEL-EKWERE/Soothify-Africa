import 'package:get/get.dart';

import '../../../../data/repositories/mood_repository.dart';
import '../controller/mood_record_controller.dart';

class MoodRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MoodRecordController(Get.find<MoodRepository>()));
  }
}
