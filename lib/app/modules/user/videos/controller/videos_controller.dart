import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../core/utils/filter_entry.dart';
import '../../../../core/utils/media_entry.dart';
import '../../../../data/models/media_filter.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/repositories/content_repository.dart';

/// One category row on the Videos screen.
class VideoShelf {
  const VideoShelf(this.title, this.query);

  final String title;
  final String query;
}

/// Backs the video library — Figma "Video Contents" (`259:60948`).
///
/// A search row over a shelf per category, each with its own See All. Same
/// shape as a [LibraryController], but the axis is the medium rather than the
/// wellness section, so the two do not share a controller.
class VideosController extends BaseController {
  VideosController(this._repository);

  final ContentRepository _repository;

  /// The frame's two rows. It writes the first as "PIlates" — a typo, not a
  /// second spelling — and leaves "Yoga" as the practice, which the section
  /// rename did not cover.
  static const List<VideoShelf> catalogue = [
    VideoShelf('Pilates', 'videos-pilates'),
    VideoShelf('Yoga', 'videos-yoga'),
  ];

  final RxMap<String, List<MediaItem>> shelves =
      <String, List<MediaItem>>{}.obs;

  final Rx<FilterSelection> filters = FilterSelection().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
        final results = await Future.wait(
          catalogue.map((s) => _repository.getShelf(s.query)),
        );
        shelves.assignAll({
          for (var i = 0; i < catalogue.length; i++)
            catalogue[i].title: results[i]
                .where((m) => filters.value.matchesDuration(m.durationSeconds))
                .toList(),
        });
      });

  /// "Pilates video content" (`259:61062`) is the See All grid — the same
  /// two-column page every other shelf opens, with the search row the frame
  /// puts above it.
  void openShelf(String shelf) => Get.toNamed(
        AppRoutes.shelf,
        arguments: {'shelf': shelf, 'search': true},
      );

  void open(MediaItem item, {required String source}) =>
      openMedia(item, source: source);

  Future<void> openFilters() async {
    final applied = await openFilterSheets(filters.value);
    if (applied == null) return;
    filters.value = applied;
    await load();
  }

  void openSearch() => AppFeedback.info('Search is not built yet.');
}
