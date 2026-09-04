import 'package:get/get.dart';

import '../../../../data/repositories/profile_repository.dart';
import '../controller/profile_tab_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileTabController(Get.find<ProfileRepository>()));
  }
}
