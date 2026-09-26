import 'package:get/get.dart';

import '../../dashboard/controller/expert_dashboard_controller.dart';
import '../controller/payout_controller.dart';

class PayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => PayoutController(Get.find<ExpertDashboardController>()),
    );
  }
}
