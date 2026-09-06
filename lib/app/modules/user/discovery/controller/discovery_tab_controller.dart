import 'package:get/get.dart';

import '../../../../core/utils/media_entry.dart';
import '../../../../core/base_controller.dart';
import '../../../../core/utils/feedback_utils.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/models/subscription_plan.dart';
import '../../../../data/repositories/content_repository.dart';
import '../../../../data/repositories/subscription_repository.dart';

/// Backs the Discovery tab — Figma "Discovery" (135:3363).
class DiscoveryTabController extends BaseController {
  DiscoveryTabController(this._content, this._subscriptions);

  final ContentRepository _content;
  final SubscriptionRepository _subscriptions;

  final RxList<MediaItem> recent = <MediaItem>[].obs;
  final RxList<MediaItem> popular = <MediaItem>[].obs;
  final RxList<SubscriptionPlan> plans = <SubscriptionPlan>[].obs;

  /// The tier whose row is outlined in blue. The design ships "One time"
  /// selected, so that is the initial value rather than nothing.
  final RxString selectedPlanId = 'one-time'.obs;

  final RxBool freeTrial = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
        final results = await Future.wait([
          _content.getRecent(),
          _content.getByCategory('discovery-popular'),
        ]);
        recent.assignAll(results[0]);
        popular.assignAll(results[1]);
        plans.assignAll(await _subscriptions.getPlans());
      });

  void selectPlan(String id) => selectedPlanId.value = id;

  void toggleFreeTrial(bool value) => freeTrial.value = value;

  void subscribe() => AppFeedback.info('Checkout is not built yet.');

  /// Each shelf's "See All" opens the same grid, named by its heading.
  void openShelf(String shelf) =>
      Get.toNamed(AppRoutes.shelf, arguments: shelf);

  void openFilters() => AppFeedback.info('Filters are not built yet.');

  /// The search field has its own frames in the design (Discovery/search,
  /// /search input, /searched result, /search/no result); none are built.
  void openSearch() => AppFeedback.info('Search is not built yet.');

  void open(MediaItem item, {String source = 'Discovery'}) =>
      openMedia(item, source: source);
}
