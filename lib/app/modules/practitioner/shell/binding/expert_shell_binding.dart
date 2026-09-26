import 'package:get/get.dart';

import '../../../../data/repositories/expert_repository.dart';
import '../../../../data/repositories/mock_expert_repository.dart';
import '../../dashboard/controller/expert_dashboard_controller.dart';
import '../controller/expert_shell_controller.dart';

/// The expert role's dependencies.
///
/// The repository is bound here rather than in [InitialBindings]: a client
/// never touches it, and binding it at startup would load the expert's data
/// for everyone.
class ExpertShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpertRepository>(() => MockExpertRepository(), fenix: true);
    Get.lazyPut(ExpertShellController.new);
    Get.lazyPut(() => ExpertDashboardController(Get.find<ExpertRepository>()));
  }
}
