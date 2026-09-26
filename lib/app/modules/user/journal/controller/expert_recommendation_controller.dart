import '../../../../core/app_export.dart';
import '../../../../data/models/expert_recommendation.dart';

/// Backs one recommendation's detail — Figma "Journal" (`259:60842`).
class ExpertRecommendationController extends GetxController {
  ExpertRecommendationController()
      : recommendation = Get.arguments is ExpertRecommendation
            ? Get.arguments as ExpertRecommendation
            : ExpertRecommendation.sample().first;

  final ExpertRecommendation recommendation;

  /// Nothing plays yet: the recommended piece is the expert's own pick and
  /// has no item in the catalogue behind it.
  void open() => AppFeedback.info(
        '${recommendation.content.kind.action} is not available yet.',
      );
}
