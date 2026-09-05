import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/repositories/content_repository.dart';

/// Backs a shelf's "See All" page — Figma "Balance Content" (135:20135).
class ShelfController extends BaseController {
  ShelfController(this._repository, this.shelf);

  final ContentRepository _repository;

  /// The shelf's heading, reused as the page title.
  final String shelf;

  final RxList<MediaItem> items = <MediaItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
        items.assignAll(await _repository.getShelfPage(shelf));
      });

  void open(MediaItem item) =>
      AppFeedback.info('${item.title} is not built yet.');
}
