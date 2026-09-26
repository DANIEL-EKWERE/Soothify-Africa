import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../core/utils/media_entry.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/models/mood.dart';
import '../../../../data/repositories/content_repository.dart';

/// Backs the post-check-in recommendation — Figma `Recommendation | <mood>`
/// (page 124:2, ten frames on the row at y=5137).
///
/// The mood is already recorded by the time this opens; this is what the app
/// offers in response to it.
class MoodRecommendationController extends BaseController {
  MoodRecommendationController(this._content, this.level);

  final ContentRepository _content;

  /// Which of the ten the user landed on. Decides the copy, and will decide
  /// the picks once the API can filter by mood.
  final MoodLevel level;

  final RxList<MediaItem> items = <MediaItem>[].obs;

  /// The design's own words for this mood — one line per mood, none shared.
  String get intro => level.recommendationIntro;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
        // Three cards, as every one of the ten frames draws. The picks are
        // not mood-filtered yet: the repository has no mood dimension, and
        // inventing one would fake a personalisation that is not there.
        final all = await _content.getRecommendations();
        items.assignAll(all.take(3));
      });

  void open(MediaItem item) =>
      openMedia(item, source: 'Mood Checker');

  /// The frames draw no forward action, and the day's check-in follows this
  /// screen, so leaving it lands there rather than going back to the slider.
  void done() => Get.offNamed(AppRoutes.moodRecord);
}
