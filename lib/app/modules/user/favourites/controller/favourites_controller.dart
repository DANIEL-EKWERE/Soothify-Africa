import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../core/utils/media_entry.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/repositories/content_repository.dart';

/// Everything the client has hearted — reached from Settings.
class FavouritesController extends BaseController {
  FavouritesController(this._content);

  final ContentRepository _content;

  final RxList<MediaItem> items = <MediaItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
        items.assignAll(await _content.getFavourites());
      });

  void open(MediaItem item) => openMedia(item, source: 'Favourites');

  /// Unhearting something here takes it off the list it is on.
  ///
  /// Removed at once rather than after the server answers: the row the
  /// finger is on should go when it is tapped. It comes back on the next
  /// load if the call failed, which is the honest answer.
  Future<void> remove(MediaItem item) async {
    final at = items.indexWhere((m) => m.id == item.id);
    if (at < 0) return;
    items.removeAt(at);

    try {
      await _content.setFavourite(item.id, on: false);
    } catch (error) {
      items.insert(at, item);
      AppFeedback.error(error);
    }
  }
}
