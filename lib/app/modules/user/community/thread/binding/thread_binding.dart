import 'package:get/get.dart';

import '../../../../../data/models/discussion.dart';
import '../../../../../data/repositories/community_repository.dart';
import '../controller/thread_controller.dart';

/// Takes the thread's post from the route arguments — the list already holds
/// it, so the screen opens with the card filled rather than empty.
class ThreadBinding extends Bindings {
  @override
  void dependencies() {
    final discussion = Get.arguments as Discussion;
    Get.lazyPut(
      () => ThreadController(Get.find<CommunityRepository>(), discussion),
    );
  }
}
