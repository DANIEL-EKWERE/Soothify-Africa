import 'package:get/get.dart';

import '../../../../data/models/checkin_kind.dart';
import '../../../../data/repositories/mood_repository.dart';
import '../controller/checkin_controller.dart';

class CheckinBinding extends Bindings {
  @override
  void dependencies() {
    final kind = Get.arguments is CheckinKind
        ? Get.arguments as CheckinKind
        : CheckinKind.mood;
    Get.lazyPut(() => CheckinController(Get.find<MoodRepository>(), kind));
  }
}
