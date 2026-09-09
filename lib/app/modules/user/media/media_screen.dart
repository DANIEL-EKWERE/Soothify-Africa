import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/gradient_text.dart';
import 'controller/media_controller.dart';

/// A media item's detail — Figma "Meditation" (135:12484).
///
/// The player sits over the cover art with a 40% scrim, then the written
/// material: title, rating, description, instructor and notes. 135:12373 is
/// the same screen before playback starts, which is this screen's paused
/// state rather than a second layout.
class MediaScreen extends GetView<MediaController> {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

class _Player extends StatelessWidget {
  const _Player();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MediaController>();
    return SizedBox(
      height: 318.v,
      child: Stack(
        children: [
          Positioned.fill(
            // The far end of the grid card's flight.
            child: Hero(
              tag: 'cover-${controller.item.id}',
              child: CustomImageView(
                imagePath: controller.item.coverAsset,
                fit: BoxFit.cover,
                radius: BorderRadius.circular(8.h),
              ),
            ),
          ),
          // The frame darkens the art by 40% so the controls stay legible
          // whatever the cover happens to be.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8.h),
              ),
            ),
          ),
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SeekButton(
                  icon: Icons.replay_10,
                  onTap: () => controller.seekBy(const Duration(seconds: -10)),
                ),
                SizedBox(width: 56.h),
                Obx(() => InkWell(
                      onTap: controller.togglePlay,
                      customBorder: const CircleBorder(),
                      child: Icon(
                        controller.playing.value
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 44.h,
                        color: appTheme.onPrimary,
                      ),
                    )),
                SizedBox(width: 56.h),
                _SeekButton(
                  icon: Icons.forward_10,
                  onTap: () => controller.seekBy(const Duration(seconds: 10)),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16.h,
            right: 16.h,
            bottom: 14.v,
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.elapsedLabel,
                      style: CustomTextStyles.playerTime,
                    ),
                    SizedBox(height: 4.v),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24.h),
                      child: LinearProgressIndicator(
                        value: controller.progress,
                        minHeight: 4.v,
                        backgroundColor: appTheme.onPrimary,
                        valueColor:
                            AlwaysStoppedAnimation(appTheme.soothifyBlue),
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
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
