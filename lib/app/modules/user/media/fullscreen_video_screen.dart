import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../core/app_export.dart';
import 'controller/media_controller.dart';

/// The video filling the screen, portrait or landscape as the device is
/// held.
///
/// It plays the very same [VideoPlayerController] the media screen is
/// holding rather than opening a second one: a fullscreen that re-buffers
/// from the start is not the same video, and on a Nigerian mobile
/// connection it is a minute of waiting to see what was already playing.
class FullscreenVideoScreen extends StatefulWidget {
  const FullscreenVideoScreen({super.key});

  @override
  State<FullscreenVideoScreen> createState() => _FullscreenVideoScreenState();
}

class _FullscreenVideoScreenState extends State<FullscreenVideoScreen> {
  /// Null when this route was reached without the screen that owns the
  /// player — it is pushed over [AppRoutes.media] and has nothing of its
  /// own to show otherwise.
  MediaController? get controller =>
      Get.isRegistered<MediaController>() ? Get.find<MediaController>() : null;

  @override
  void initState() {
    super.initState();
    // Either way up while this is open, and the system bars out of the way.
    // Not landscape-only: a portrait clip — which is most of what a phone
    // records — is letterboxed into bars by a forced rotation, and somebody
    // watching in bed should not have the picture turn sideways on them.
    // The app is portrait-locked everywhere else, so this is the one screen
    // that follows the device.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // The app is portrait everywhere else — see main().
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // The null check sits outside the Obx deliberately: an Obx that
      // returns before reading an observable has registered nothing, and
      // GetX throws "improper use of a GetX" rather than drawing the empty
      // screen this route falls back to.
      body: Builder(builder: (context) {
        final media = controller;
        if (media == null) return const SizedBox.shrink();
        return Obx(() {
        final video = media.ready.value ? media.video : null;
        if (video == null) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        return Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: video.value.aspectRatio,
                child: VideoPlayer(video),
              ),
            ),
            Positioned(
              top: 16.v,
              left: 16.h,
              child: SafeArea(
                child: GestureDetector(
                  onTap: Get.back,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 36.h,
                    height: 36.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.fullscreen_exit_rounded,
                        size: 22.h, color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24.h,
              right: 24.h,
              bottom: 24.v,
              child: SafeArea(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: media.togglePlay,
                      behavior: HitTestBehavior.opaque,
                      child: Icon(
                        media.playing.value
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 36.h,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16.h),
                    Text(media.elapsedLabel,
                        style: CustomTextStyles.playerTime),
                    SizedBox(width: 16.h),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24.h),
                        child: LinearProgressIndicator(
                          value: media.progress,
                          minHeight: 4.v,
                          backgroundColor: appTheme.onPrimary,
                          valueColor:
                              AlwaysStoppedAnimation(appTheme.soothifyBlue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
        });
      }),
    );
  }
}
