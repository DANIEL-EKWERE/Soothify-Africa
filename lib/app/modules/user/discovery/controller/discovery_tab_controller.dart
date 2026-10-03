import 'package:get/get.dart';

import '../../../../core/utils/filter_entry.dart';
import '../../../../core/utils/media_entry.dart';
import '../../../../core/base_controller.dart';
import '../../../../core/utils/feedback_utils.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/models/media_filter.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/models/subscription_offer.dart';
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

  /// The tier whose row is outlined in blue. The design ships the first one
  /// selected, so that is the initial value rather than nothing.
  final RxString selectedPlanId = 'core'.obs;

  final RxBool freeTrial = false.obs;

  /// The same filter flow the libraries use; Discovery's glyph is the same
  /// glyph.
  final Rx<FilterSelection> filters = FilterSelection().obs;

  @override
  void onInit() {
    super.onInit();
    load();
    // GetX's own worker rather than a Timer, so it is torn down with the
    // controller and cannot fire into a disposed screen.
    debounce(query, (_) => runSearch(),
        time: const Duration(milliseconds: 400));
  }

  Future<void> load() => guard(() async {
    final results = await Future.wait([
      _content.getRecent(),
      _content.getByCategory('discovery-popular'),
    ]);
    bool keep(MediaItem m) => filters.value.matchesDuration(m.durationSeconds);
    recent.assignAll(results[0].where(keep));
    popular.assignAll(results[1].where(keep));
    plans.assignAll(await _subscriptions.getPlans());
  });

  void selectPlan(String id) => selectedPlanId.value = id;

  void toggleFreeTrial(bool value) => freeTrial.value = value;

  /// The pop-up is the pitch the design puts behind this — `259:59011`.
  void subscribe() => Get.toNamed(
        AppRoutes.subscriptionOffer,
        arguments: SubscriptionOffer.trial,
      );

  /// Each shelf's "See All" opens the same grid, named by its heading.
  void openShelf(String shelf) =>
      Get.toNamed(AppRoutes.shelf, arguments: shelf);

  Future<void> openFilters() async {
    final applied = await openFilterSheets(filters.value);
    if (applied == null) return;
    filters.value = applied;
    await load();
  }

  // ---- Search -------------------------------------------------------------
  //
  // The design has four frames for this (Discovery/search, /search input,
  // /searched result, /search/no result). Only the "searching" one was
  // supplied as a screenshot, so that state is measured and the result and
  // empty states reuse Discovery's own card and type.

  /// True once the field is tapped: the shelves and the subscription card
  /// give way to the search surface until [closeSearch].
  final RxBool searching = false.obs;

  final RxString query = ''.obs;

  /// Separate from [isLoading] so a search in flight never blanks the tab's
  /// own content, and so the spinner row is driven by one flag only.
  final RxBool searchBusy = false.obs;

  final RxList<MediaItem> results = <MediaItem>[].obs;

  /// Set once a search has actually run, so the empty state is not shown
  /// against the blank field the screen opens with.
  final RxBool searched = false.obs;

  void openSearch() => searching.value = true;

  void closeSearch() {
    searching.value = false;
    query.value = '';
    results.clear();
    searchBusy.value = false;
    searched.value = false;
  }

  /// Typing shows the spinner immediately; the request itself waits for the
  /// debounce below, so a fast typist makes one call rather than one a key.
  void onQueryChanged(String value) {
    query.value = value;
    final text = value.trim();
    searchBusy.value = text.isNotEmpty;
    if (text.isEmpty) {
      results.clear();
      searched.value = false;
    }
  }

  Future<void> runSearch() async {
    final text = query.value.trim();
    if (text.isEmpty) {
      searchBusy.value = false;
      return;
    }
    searchBusy.value = true;
    try {
      final found = await _content.search(text);
      // A stale response: the field moved on while this was in flight.
      if (text != query.value.trim()) return;
      results.assignAll(found);
      searched.value = true;
    } catch (_) {
      if (text != query.value.trim()) return;
      results.clear();
      searched.value = true;
      AppFeedback.error('Search failed. Check your connection and try again.');
    } finally {
      if (text == query.value.trim()) searchBusy.value = false;
    }
  }

  void open(MediaItem item, {String source = 'Discovery'}) =>
      openMedia(item, source: source);
}
