import 'package:get/get.dart';

import '../../../../data/models/mood.dart';
import '../../../../data/repositories/content_repository.dart';
import '../controller/mood_recommendation_controller.dart';

/// Takes the mood from the route arguments, so one route serves all ten.
class MoodRecommendationBinding extends Bindings {
  @override
  void dependencies() {
    final level = Get.arguments is MoodLevel
        ? Get.arguments as MoodLevel
        : MoodLevel.neutral;
    Get.lazyPut(
      () => MoodRecommendationController(Get.find<ContentRepository>(), level),
    );
  }
}
