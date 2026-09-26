import 'package:get/get.dart';

import '../controller/expert_application_controller.dart';

/// Shared by the intro and the form, so "Start Application" carries straight
/// into a controller that is already alive.
class ExpertApplicationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(ExpertApplicationController.new, fenix: true);
  }
}
