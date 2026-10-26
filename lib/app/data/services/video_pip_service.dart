import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../models/media_item.dart';

/// Keeps a playing video alive after its screen is gone.
///
/// Leaving a video halfway used to stop it dead: the screen owned the player
/// and disposed it on the way out. The player lives here instead, so closing
/// the screen hands it over rather than ending it, and a small window keeps
/// it playing until the user closes that too.
///
/// A service, not a controller: it has to outlive every route, which is the
/// whole point of it.
class VideoPipService extends GetxService {
  /// The running player, or null when nothing is floating.
  final Rxn<VideoPlayerController> player = Rxn<VideoPlayerController>();

  /// What is playing, so the window can name it and reopen its screen.
  final Rxn<MediaItem> item = Rxn<MediaItem>();

  /// The shelf the item was opened from — the media screen's header shows
  /// it, so reopening has to carry it back.
  String source = '';

  bool get showing => player.value != null;

  /// Takes a running player off a screen that is closing.
  ///
  /// Whatever was floating before is disposed: two videos playing at once is
  /// never what anybody meant.
  void adopt(
    VideoPlayerController playing,
    MediaItem playingItem, {
    required String from,
  }) {
    final previous = player.value;
    if (previous != null && previous != playing) previous.dispose();
    player.value = playing;
    item.value = playingItem;
    source = from;
  }

  /// Hands the player back to a screen reopening on the same item, so it
  /// carries on from where the window had it rather than starting again.
  ///
  /// Returns null for any other item, and the caller opens its own.
  VideoPlayerController? release(String itemId) {
    final playing = player.value;
    if (playing == null || item.value?.id != itemId) return null;
    player.value = null;
    item.value = null;
    source = '';
    return playing;
  }

  /// The window's close button, and anything else that ends the playback.
  void close() {
    player.value?.dispose();
    player.value = null;
    item.value = null;
    source = '';
  }

  @override
  void onClose() {
    close();
    super.onClose();
  }
}

/// The service, registered on first use.
///
/// Reached from the media screen and from the overlay, neither of which can
/// be sure which ran first.
VideoPipService get videoPip => Get.isRegistered<VideoPipService>()
    ? Get.find<VideoPipService>()
    : Get.put(VideoPipService(), permanent: true);
