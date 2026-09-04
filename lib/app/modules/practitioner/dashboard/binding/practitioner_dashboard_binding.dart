import 'package:get/get.dart';

import '../controller/practitioner_dashboard_controller.dart';

class PractitionerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PractitionerDashboardController());
  }
}
