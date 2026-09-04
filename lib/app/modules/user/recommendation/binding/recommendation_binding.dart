import 'package:get/get.dart';

import '../../../../data/repositories/content_repository.dart';
import '../controller/recommendation_controller.dart';

class RecommendationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => RecommendationController(Get.find<ContentRepository>()),
    );
  }
}
