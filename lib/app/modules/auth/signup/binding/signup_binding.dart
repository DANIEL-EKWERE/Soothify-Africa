import 'package:get/get.dart';

import '../../../../data/services/session_service.dart';
import '../controller/signup_controller.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignupController(Get.find<SessionService>()));
  }
}
