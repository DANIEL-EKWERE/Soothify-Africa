import 'package:get/get.dart';

import '../../../../data/repositories/kyc_repository.dart';
import '../controller/kyc_controller.dart';

class KycBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => KycController(Get.find<KycRepository>()));
  }
}
