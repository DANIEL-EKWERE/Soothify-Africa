import 'package:get/get.dart';

import '../../../../data/services/session_service.dart';
import '../controller/role_select_controller.dart';

class RoleSelectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RoleSelectController(Get.find<SessionService>()));
  }
}
