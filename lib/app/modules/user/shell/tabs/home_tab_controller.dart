import 'package:get/get.dart';

import '../../../../core/base_controller.dart';
import '../../../../core/utils/feedback_utils.dart';
import '../../../../data/models/explore_destination.dart';
import '../../../../data/models/library_section.dart';
import '../../../../core/utils/wellness_entry.dart';
import '../../../../data/models/wellness_kyc.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/repositories/content_repository.dart';

/// Backs the Home tab.
///
/// Sections come from the design: a Mood Checker entry, three fixed Explore
/// destinations, a "Recommended for you" list and a "Popular Content" row.
class HomeTabController extends BaseController {
  HomeTabController(this._repository);

  final ContentRepository _repository;

  final RxList<MediaItem> recommended = <MediaItem>[].obs;
  final RxList<MediaItem> popular = <MediaItem>[].obs;

  /// Static, not loaded — these are navigation targets.
  List<ExploreDestination> get explore => ExploreDestination.values;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    await guard(() async {
      final results = await Future.wait([
        _repository.getFeatured(),
        _repository.getByCategory('popular'),
      ]);
      recommended.assignAll(results[0]);
      popular.assignAll(results[1]);
    });
  }

  Future<void> reload() => load();

  /// All three Explore tiles now have a screen. Meditation and Balance share
  /// one, distinguished by the argument.
  void openExplore(ExploreDestination destination) {
    switch (destination) {
      case ExploreDestination.meditation:
        Get.toNamed(AppRoutes.library, arguments: LibrarySection.meditation);
      case ExploreDestination.balance:
        Get.toNamed(AppRoutes.library, arguments: LibrarySection.balance);
      case ExploreDestination.scheduleSession:
        // First time through, the questionnaire comes before booking.
        openBooking(WellnessTrack.schedule);
    }
  }

  void seeAllPopular() => AppFeedback.info('Popular Content is not built yet.');

  void openAiAssist() =>
      AppFeedback.info('AI Therapy Assist is not built yet.');
}
