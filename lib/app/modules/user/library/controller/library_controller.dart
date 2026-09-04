import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/library_section.dart';
import '../../../../data/models/media_item.dart';
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

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
        // No shelf-specific endpoint exists yet, so every shelf draws from the
        // same pool. The shape is what matters here; the queries change when
        // the API lands.
        final items = await _repository.getRecent();
        shelves.assignAll({for (final s in section.shelves) s: items});
      });

  void openShelf(String shelf) => AppFeedback.info('$shelf is not built yet.');

  void open(MediaItem item) =>
      AppFeedback.info('${item.title} is not built yet.');

  void openSearch() => AppFeedback.info('Search is not built yet.');
}
