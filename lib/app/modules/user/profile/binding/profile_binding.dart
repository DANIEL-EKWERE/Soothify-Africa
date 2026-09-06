import 'package:get/get.dart';

import '../../../../data/repositories/profile_repository.dart';
import '../../../../data/services/session_service.dart';
import '../controller/profile_tab_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileTabController(
          Get.find<ProfileRepository>(),
          Get.find<SessionService>(),
        ));
  }
}
