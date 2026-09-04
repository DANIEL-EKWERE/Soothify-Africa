import 'package:get/get.dart';

import '../../../../../data/repositories/community_repository.dart';
import '../controller/forum_controller.dart';

class ForumBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut(() => ForumController(Get.find<CommunityRepository>()));
}
