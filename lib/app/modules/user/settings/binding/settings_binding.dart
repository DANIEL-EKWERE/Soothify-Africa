import 'package:get/get.dart';

import '../../../../data/services/session_service.dart';
import '../../../../data/services/theme_service.dart';
import '../controller/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsController(
          Get.find<ThemeService>(),
          Get.find<SessionService>(),
        ));
  }
}
