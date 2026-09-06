import 'package:get/get.dart';

import '../../../../data/repositories/content_repository.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../../../../data/services/session_service.dart';
import '../../../../data/repositories/subscription_repository.dart';
import '../../community/controller/community_tab_controller.dart';
import '../../discovery/controller/discovery_tab_controller.dart';
import '../../plans/controller/plans_tab_controller.dart';
import '../../profile/controller/profile_tab_controller.dart';
import '../../mood_checker/controller/mood_checker_controller.dart';
import '../../../../data/repositories/mood_repository.dart';
import '../controller/shell_controller.dart';
import '../tabs/home_tab_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ShellController());
    Get.lazyPut(() => HomeTabController(Get.find<ContentRepository>()));
    // The Home tab links straight into the mood checker, so its controller
    // must be resolvable from here too.
    Get.lazyPut(() => MoodCheckerController(Get.find<MoodRepository>()));
    Get.lazyPut(() => ProfileTabController(
          Get.find<ProfileRepository>(),
          Get.find<SessionService>(),
        ));
    Get.lazyPut(() => PlansTabController(Get.find<SubscriptionRepository>()));
    Get.lazyPut(() => CommunityTabController());
    Get.lazyPut(() => DiscoveryTabController(
          Get.find<ContentRepository>(),
          Get.find<SubscriptionRepository>(),
        ));
  }
}
