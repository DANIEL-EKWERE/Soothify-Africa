import '../../../../core/app_export.dart';
import '../../../../core/utils/media_entry.dart';
import '../../../../core/base_controller.dart';
import '../../../../core/utils/filter_entry.dart';
import '../../../../data/models/media_filter.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/repositories/content_repository.dart';

/// Backs a shelf's "See All" page — Figma "Balance Content" (135:20135).
class ShelfController extends BaseController {
  ShelfController(this._repository, this.shelf, {this.showSearch = false});

  final ContentRepository _repository;

  /// The shelf's heading, reused as the page title.
  final String shelf;

  /// Whether a search row sits above the grid. Only the Videos screen's See
  /// All draws one; every other "See All" frame goes straight to the cards.
  final bool showSearch;

  final RxList<MediaItem> items = <MediaItem>[].obs;

  final Rx<FilterSelection> filters = FilterSelection().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
        final page = await _repository.getShelfPage(shelf);
        items.assignAll(
          page
              .where((m) => filters.value.matchesDuration(m.durationSeconds))
              .toList(),
        );
      });

  void open(MediaItem item) => openMedia(item, source: shelf);

  Future<void> openFilters() async {
    final applied = await openFilterSheets(filters.value);
    if (applied == null) return;
    filters.value = applied;
    await load();
  }

  void openSearch() => AppFeedback.info('Search is not built yet.');
}
