import 'package:flutter/widgets.dart';

import '../../../../core/app_export.dart';
import '../../../../core/utils/media_entry.dart';
import '../../../../core/base_controller.dart';
import '../../../../core/utils/filter_entry.dart';
import '../../../../data/models/media_filter.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/repositories/content_repository.dart';

/// Backs a shelf's "See All" page — Figma "Balance Content" (135:20135).
class ShelfController extends BaseController {
  ShelfController(
    this._repository,
    this.shelf, {
    String key = '',
    this.showSearch = false,
  }) : key = key.isEmpty ? _slug(shelf) : key;

  final ContentRepository _repository;

  /// The shelf's heading, reused as the page title.
  final String shelf;

  /// Which shelf to ask the server for.
  ///
  /// Not the heading: the API routes shelves by slug, so "Voice Overs" was
  /// a 404 and every See All grid came back empty against the live backend.
  /// The two are not derivable from each other either — "Movement" is
  /// `pilates-movement` in one library section and `balance-movement` in
  /// the other — so
  /// the caller passes the catalogue's own query and the slug of the
  /// heading is only a fallback for callers that have none.
  final String key;

  /// Home's two rows are not shelves: nothing on the server answers to
  /// `recent` or `popular`, and their See All has to go back to the same
  /// call that filled the row.
  static const _recent = 'recent';
  static const _popular = 'popular';

  static String _slug(String heading) =>
      heading.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

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
        final page = switch (key) {
          _recent => await _repository.getRecent(),
          // getPopular, not getFeatured: the rows this grid is the rest of
          // are filled by the former — what people are actually playing,
          // staff pins first. Featured is a different list, so both
          // Popular "See All"s were opening on content the row never
          // showed.
          _popular => await _repository.getPopular(),
          // Sent to the server, so a chip narrows the catalogue rather
          // than the page already fetched.
          _ => await _repository.getShelfPage(
            key,
            filters: filters.value.queryParams,
          ),
        };
        items.assignAll(
          page
              .where((m) => filters.value.matchesDuration(m.durationSeconds))
              .toList(),
        );
      });

  void open(MediaItem item) => openMedia(item, source: shelf);

  Future<void> openFilters(BuildContext anchor) async {
    final applied = await openFilterSheets(anchor, filters.value);
    if (applied == null) return;
    filters.value = applied;
    await load();
  }

  /// The library is searched on the server -- titles, practitioners and
  /// tags across everything, which filtering one loaded shelf could not do.
  void openSearch() => Get.toNamed(AppRoutes.librarySearch);
}
