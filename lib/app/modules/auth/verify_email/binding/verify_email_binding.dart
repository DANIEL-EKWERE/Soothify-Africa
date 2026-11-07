import 'package:get/get.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/kyc_repository.dart';
import '../../../../data/services/session_service.dart';
import '../controller/verify_email_controller.dart';

class VerifyEmailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => VerifyEmailController(
        Get.find<AuthRepository>(),
        Get.find<SessionService>(),
        Get.find<KycRepository>(),
      ),
    );
  }
}
