import 'package:get/get.dart';

import '../../../../data/models/checkin_kind.dart';
import '../controller/daily_controller.dart';

class DailyBinding extends Bindings {
  @override
  void dependencies() {
    final kind = Get.arguments is CheckinKind
        ? Get.arguments as CheckinKind
        : CheckinKind.meditation;
    Get.lazyPut(() => DailyController(kind));
  }
}
