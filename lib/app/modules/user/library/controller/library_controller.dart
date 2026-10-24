import 'package:flutter/widgets.dart';

import '../../../../core/app_export.dart';
import '../../../../core/utils/filter_entry.dart';
import '../../../../core/utils/wellness_entry.dart';
import '../../../../core/utils/media_entry.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/library_section.dart';
import '../../../../data/models/media_filter.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/models/wellness_kyc.dart';
import '../../../../data/repositories/content_repository.dart';

/// Backs the Meditation and Balance libraries.
class LibraryController extends BaseController {
  LibraryController(this._repository, this.section);

  final ContentRepository _repository;
  final LibrarySection section;

  /// Shelf heading to its items. A map keeps the design's shelf order without
  /// pairing two parallel lists that can drift apart.
  final RxMap<String, List<MediaItem>> shelves =
      <String, List<MediaItem>>{}.obs;

  /// What the filter sheets applied. Held here rather than in the sheets so it
  /// survives them closing, and so reopening the glyph shows the current
  /// state.
  final Rx<FilterSelection> filters = FilterSelection().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
    // Each shelf is fetched by its own query: the frames give Voice Overs
    // and Sound Effects different cards, so one shared list put the wrong
    // art under the wrong heading.
    final queries = section.shelves.toList();
    final results = await Future.wait(
      queries.map((s) => _repository.getShelf(s.query)),
    );
    shelves.assignAll({
      for (var i = 0; i < queries.length; i++)
        queries[i].title: results[i]
            .where((m) => filters.value.matchesDuration(m.durationSeconds))
            .toList(),
    });
  });

  /// The heading is what the page is called; the shelf's own query is what
  /// the server is asked for. "Movement" is `pilates-movement` here and
  /// `balance-movement` in the other section, so the two cannot be derived from
  /// each other.
  void openShelf(String shelf) {
    final match = section.shelves.where((s) => s.title == shelf);
    Get.toNamed(
      AppRoutes.shelf,
      arguments: {
        'shelf': shelf,
        if (match.isNotEmpty) 'key': match.first.query,
      },
    );
  }

  /// Which questionnaire fronts this section's sessions.
  WellnessTrack get track => switch (section) {
    LibrarySection.meditation => WellnessTrack.meditation,
    LibrarySection.balance => WellnessTrack.balance,
  };

  /// Each track is gated separately — answering Meditation's questions says
  /// nothing about Balance's.
  void openSessions() => openBooking(track);

  void open(MediaItem item, {String source = ''}) =>
      openMedia(item, source: source.isEmpty ? section.title : source);

  /// Duration, More Filters and Style — Figma 135:12427, 135:12573 and
  /// 135:12833. Only duration narrows the shelves today: it is the one group
  /// the content model can answer. The rest are recorded and go to the API
  /// once there is one.
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
