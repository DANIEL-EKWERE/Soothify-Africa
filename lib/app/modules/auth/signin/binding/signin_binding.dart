import 'package:get/get.dart';

import '../../../../data/repositories/kyc_repository.dart';
import '../../../../data/services/session_service.dart';
import '../controller/signin_controller.dart';

class SigninBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => SigninController(
        Get.find<SessionService>(),
        Get.find<KycRepository>(),
      ),
    );
  }
}
