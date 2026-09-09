import 'package:get/get.dart';

import '../../../../data/repositories/notification_repository.dart';
import '../controller/notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => NotificationsController(Get.find<NotificationRepository>()),
    );
  }
}
