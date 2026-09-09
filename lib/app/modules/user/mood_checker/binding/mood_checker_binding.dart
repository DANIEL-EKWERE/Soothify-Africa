import 'package:get/get.dart';

import '../../../../data/repositories/kyc_repository.dart';
import '../../../../data/repositories/mood_repository.dart';
import '../controller/mood_checker_controller.dart';

class MoodCheckerBinding extends Bindings {
  @override
  void dependencies() {
    // KYC comes in for the gender answer, which decides whose face is drawn.
    Get.lazyPut(
      () => MoodCheckerController(
        Get.find<MoodRepository>(),
        Get.find<KycRepository>(),
      ),
    );
  }
}
