import 'package:get/get.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/kyc_repository.dart';
import '../../../../data/services/session_service.dart';
import '../controller/forgot_password_controller.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ForgotPasswordController(
        Get.find<AuthRepository>(),
        Get.find<SessionService>(),
        Get.find<KycRepository>(),
      ),
    );
  }
}
