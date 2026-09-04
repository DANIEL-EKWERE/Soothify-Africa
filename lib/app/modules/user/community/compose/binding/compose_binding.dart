import 'package:get/get.dart';

import '../../../../../data/repositories/community_repository.dart';
import '../controller/compose_controller.dart';

class ComposeBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut(() => ComposeController(Get.find<CommunityRepository>()));
}
