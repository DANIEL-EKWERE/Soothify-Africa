import 'package:get/get.dart';

import '../../../../data/repositories/expert_application_repository.dart';
import '../controller/expert_application_controller.dart';

/// Shared by the intro and the form, so "Start Application" carries straight
/// into a controller that is already alive.
class ExpertApplicationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ExpertApplicationController(
        Get.find<ExpertApplicationRepository>(),
      ),
      fenix: true,
    );
  }
}
