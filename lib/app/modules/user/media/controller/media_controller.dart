import '../../../../core/app_export.dart';
import '../../../../data/models/media_item.dart';

/// Backs the media detail screen — Figma "Meditation" (135:12484, and
/// 135:12373 for the not-yet-playing preview state).
class MediaController extends GetxController {
  MediaController(this.item, {required this.source});

  /// Passed in rather than refetched: every card that opens this screen
  /// already holds the item, and refetching would blank the page on open.
  final MediaItem item;

  /// The shelf the card was tapped on — the frame's header shows it ("Top
  /// Picks for you", "Sleep Stories"), so it belongs to the caller.
  final String source;

  /// The design shows 2:34 of 15:00. Nothing plays yet, so this is the
  /// position the frame draws rather than a live one.
  final Rx<Duration> position = const Duration(minutes: 2, seconds: 34).obs;

  final RxBool playing = false.obs;

  Duration get total => item.duration;

  double get progress => total.inSeconds == 0
      ? 0
      : (position.value.inSeconds / total.inSeconds).clamp(0.0, 1.0);

  String get elapsedLabel => '${_mmss(position.value)} / ${_mmss(total)}';

  static String _mmss(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  /// The frame prints "15 mins" beside the rating.
  String get durationLabel => '${total.inMinutes} mins';

  String get ratingLabel =>
      '${item.rating == 0 ? '—' : item.rating.toStringAsFixed(1)}/5';

  void togglePlay() {
    playing.toggle();
    AppFeedback.info('Playback arrives with the backend.');
  }

  void seekBy(Duration delta) {
    final next = position.value + delta;
    position.value = next < Duration.zero
        ? Duration.zero
        : (next > total ? total : next);
  }

  void addNote() => Get.toNamed(AppRoutes.journalCompose);
}
