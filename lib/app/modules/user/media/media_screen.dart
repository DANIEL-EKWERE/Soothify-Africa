import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/app_export.dart';
import '../../../widgets/gradient_text.dart';
import 'controller/media_controller.dart';

/// A media item's detail — Figma "Meditation" (135:12484).
///
/// The player sits over the cover art with a 40% scrim, then the written
/// material: title, rating, description, instructor and notes. 135:12373 is
/// the same screen before playback starts, which is this screen's paused
/// state rather than a second layout.
/// Shown when the route was reached without an item to play.
class _CouldNotOpen extends StatelessWidget {
  const _CouldNotOpen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'That content could not be opened.',
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.emptyStateBody,
                ),
                SizedBox(height: 16.v),
                TextButton(
                  onPressed: Get.back,
                  child: Text(
                    'Go back',
                    style: CustomTextStyles.emptyStateBody.copyWith(
                      color: appTheme.soothifyBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MediaScreen extends GetView<MediaController> {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Nothing to show: the route was opened without an item, which until
    // now drew a blank grey screen that said nothing about why. Everything
    // should go through `openMedia`; this is what is left if something
    // does not.
    if (!Get.isRegistered<MediaController>()) return const _CouldNotOpen();

    final item = controller.item;
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(23.h, 17.v, 23.h, 32.v),
          children: [
            _Header(title: controller.source),
            SizedBox(height: 35.v),
            const _Player(),
            SizedBox(height: 24.v),
            Text(item.title, style: CustomTextStyles.mediaTitle),
            SizedBox(height: 12.v),
            const _Meta(),
            SizedBox(height: 12.v),
            Text(
              item.description,
              style: CustomTextStyles.mediaBody,
            ),
            SizedBox(height: 20.v),
            const _RateIt(),
            SizedBox(height: 24.v),
            const _InstructorCard(),
            SizedBox(height: 32.v),
            const _AddNote(),
            SizedBox(height: 48.v),
            const _Facts(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: Get.back,
          child: CustomImageView(
            imagePath: ImageConstant.icBack,
            height: 18.h,
            width: 18.h,
            color: appTheme.textPrimary,
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CustomTextStyles.appBarTitle,
          ),
        ),
        SizedBox(width: 18.h),
      ],
    );
  }
}

/// The 318-tall player at the top of the screen.
///
/// Audio keeps the frame's treatment: the cover under a 40% wash with the
/// transport always on it. A video is a video — the wash comes off, the
/// controls fade out of the way while it plays and come back on a tap, the
/// bar is draggable, and there is a way to fill the screen with it.
class _Player extends StatefulWidget {
  const _Player();

  @override
  State<_Player> createState() => _PlayerState();
}

class _PlayerState extends State<_Player> {
  MediaController get controller => Get.find<MediaController>();

  /// Video only. Audio has nothing to get out of the way of.
  bool _controlsShown = true;
  Timer? _hide;

  @override
  void dispose() {
    _hide?.cancel();
    super.dispose();
  }

  /// A tap anywhere on the picture brings the controls back, and starts the
  /// clock that takes them away again.
  void _poke() {
    setState(() => _controlsShown = !_controlsShown);
    _armHide();
  }

  void _armHide() {
    _hide?.cancel();
    if (!_controlsShown) return;
    _hide = Timer(const Duration(seconds: 3), () {
      if (mounted && controller.playing.value) {
        setState(() => _controlsShown = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 318.v,
      child: Obx(() {
        final video = controller.ready.value ? controller.video : null;
        final isVideo = controller.isVideo;
        // Controls stay put on audio, and whenever a video is paused —
        // hiding them over a still frame leaves a dead rectangle.
        final shown = !isVideo || !controller.playing.value || _controlsShown;
        return GestureDetector(
          onTap: isVideo ? _poke : null,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Positioned.fill(
                // The far end of the grid card's flight.
                child: Hero(
                  tag: 'cover-${controller.item.id}',
                  child: video == null
                      ? CustomImageView(
                          imagePath: controller.item.cover,
                          fit: BoxFit.cover,
                          radius: BorderRadius.circular(8.h),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8.h),
                          child: ColoredBox(
                            color: Colors.black,
                            child: Center(
                              child: AspectRatio(
                                aspectRatio: video.value.aspectRatio,
                                child: VideoPlayer(video),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              // The frame darkens the art by 40% so the controls stay
              // legible whatever the cover happens to be. No wash over a
              // video: it is the thing being watched, not a backdrop. The
              // controls carry their own shading instead.
              if (video == null)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8.h),
                    ),
                  ),
                ),
              AnimatedOpacity(
                opacity: shown ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !shown,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SeekButton(
                              icon: Icons.replay_10,
                              onTap: () {
                                controller
                                    .seekBy(const Duration(seconds: -10));
                                _armHide();
                              },
                            ),
                            SizedBox(width: 56.h),
                            InkWell(
                              onTap: () {
                                controller.togglePlay();
                                _armHide();
                              },
                              customBorder: const CircleBorder(),
                              child: Icon(
                                controller.playing.value
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 44.h,
                                color: appTheme.onPrimary,
                              ),
                            ),
                            SizedBox(width: 56.h),
                            _SeekButton(
                              icon: Icons.forward_10,
                              onTap: () {
                                controller.seekBy(const Duration(seconds: 10));
                                _armHide();
                              },
                            ),
                          ],
                        ),
                      ),
                      // Only a video has a screen to fill.
                      if (video != null)
                        Positioned(
                          top: 8.v,
                          right: 8.h,
                          child: _SeekButton(
                            icon: Icons.fullscreen_rounded,
                            onTap: () =>
                                Get.toNamed(AppRoutes.mediaFullscreen),
                          ),
                        ),
                      Positioned(
                        left: 16.h,
                        right: 16.h,
                        // 14 in the frame, less the 8 of padding the
                        // scrubber now carries as its touch target, so the
                        // bar itself still lands where it was measured.
                        bottom: 6.v,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.elapsedLabel,
                              style: CustomTextStyles.playerTime,
                            ),
                            SizedBox(height: 4.v),
                            _Scrubber(onScrub: _armHide),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// The progress bar, draggable.
///
/// It was a plain indicator: it said where the playback had got to and took
/// nothing back. A video people watch in pieces needs to be seekable by the
/// bar, not only by the ten-second buttons.
class _Scrubber extends StatelessWidget {
  const _Scrubber({required this.onScrub});

  /// Keeps the controls up while a drag is in progress.
  final VoidCallback onScrub;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MediaController>();
    return LayoutBuilder(
      builder: (context, constraints) {
        void seekTo(double dx) {
          final width = constraints.maxWidth;
          if (width <= 0) return;
          final fraction = (dx / width).clamp(0.0, 1.0);
          controller.seekTo(controller.total * fraction);
          onScrub();
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (hit) => seekTo(hit.localPosition.dx),
          onHorizontalDragUpdate: (drag) => seekTo(drag.localPosition.dx),
          // A 4-tall bar is a hard thing to catch with a thumb; the padding
          // is the target, the bar is what it draws.
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.v),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.h),
              child: LinearProgressIndicator(
                value: controller.progress,
                minHeight: 4.v,
                backgroundColor: appTheme.onPrimary,
                valueColor: AlwaysStoppedAnimation(appTheme.soothifyBlue),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SeekButton extends StatelessWidget {
  const _SeekButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // The skip glyphs were not exported; Material stands in for these two.
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Icon(icon, size: 22.h, color: appTheme.onPrimary),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MediaController>();
    return Row(
      children: [
        CustomImageView(
          imagePath: ImageConstant.icStar,
          height: 12.h,
          width: 13.h,
          color: appTheme.accent,
        ),
        SizedBox(width: 6.h),
        Text(controller.ratingLabel, style: CustomTextStyles.mediaBody),
        SizedBox(width: 31.h),
        Text(
          controller.durationLabel,
          // Half-strength in the frame — secondary to the rating.
          style: CustomTextStyles.mediaBody
              .copyWith(color: appTheme.textPrimary.withValues(alpha: 0.5)),
        ),
      ],
    );
  }
}

class _InstructorCard extends StatelessWidget {
  const _InstructorCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MediaController>();
    return Container(
      height: 48.v,
      padding: EdgeInsets.symmetric(horizontal: 10.h),
      decoration: BoxDecoration(
        color: appTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(4.h),
      ),
      child: Row(
        children: [
          ClipOval(
            child: CustomImageView(
              imagePath: ImageConstant.imgMediaInstructor,
              height: 31.v,
              width: 28.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 18.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Instructor', style: CustomTextStyles.mediaCaption),
              Text(
                controller.item.practitionerName,
                style: CustomTextStyles.mediaInstructor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Rate this" — five stars the listener can actually press.
///
/// The screen printed an average and took nothing back: the rating endpoint
/// and [MediaController.rate] were both written, and nothing in the app
/// ever called them, so no one could rate anything.
///
/// The frame draws no input here. This is the same five-star row the
/// post-session screen uses, at the size of the meta line's own star, so it
/// reads as part of this screen rather than a control borrowed from another.
class _RateIt extends StatelessWidget {
  const _RateIt();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MediaController>();
    return Obx(
      () => Row(
        children: [
          Text(
            controller.myRating.value == 0 ? 'Rate this' : 'Your rating',
            style: CustomTextStyles.mediaBody,
          ),
          SizedBox(width: 12.h),
          for (var star = 1; star <= 5; star++)
            InkWell(
              onTap: controller.sending.value
                  ? null
                  : () => controller.rate(star),
              customBorder: const CircleBorder(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.h, vertical: 4.v),
                child: CustomImageView(
                  imagePath: ImageConstant.icStar,
                  height: 20.h,
                  width: 20.h,
                  // Filled to where this person rated it, grey past that —
                  // not the average, which is everybody's and is printed
                  // above in the meta line.
                  color: star <= controller.myRating.value
                      ? appTheme.accent
                      : appTheme.progressTrack,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddNote extends StatelessWidget {
  const _AddNote();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MediaController>();
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: controller.addNote,
        borderRadius: BorderRadius.circular(10.h),
        child: Container(
          height: 41.v,
          padding: EdgeInsets.symmetric(horizontal: 20.h),
          decoration: BoxDecoration(
            color: appTheme.surface,
            borderRadius: BorderRadius.circular(10.h),
          ),
          child: Center(
            widthFactor: 1,
            child: GradientText(
              'Add Note',
              gradient: appTheme.authHeaderGradient,
              style: CustomTextStyles.addNote,
            ),
          ),
        ),
      ),
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MediaController>();
    return Column(
      children: [
        CustomImageView(
          imagePath: ImageConstant.imgMediaBadge,
          height: 40.h,
          width: 40.h,
        ),
        SizedBox(height: 12.v),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Instructor\n${controller.item.practitionerName}',
              textAlign: TextAlign.center,
              style: CustomTextStyles.mediaFact,
            ),
            Text(
              'Duration\n${controller.durationLabel}',
              textAlign: TextAlign.center,
              style: CustomTextStyles.mediaFact,
            ),
          ],
        ),
      ],
    );
  }
}
