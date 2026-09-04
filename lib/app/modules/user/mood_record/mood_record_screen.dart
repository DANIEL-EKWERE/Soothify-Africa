import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_ghost_button.dart';
import 'controller/mood_record_controller.dart';
import 'widgets/streak_strip.dart';

/// Mood Records — Figma `135:2056`.
///
/// Shown straight after a check-in: a congratulation, the week's streak, and a
/// single way onward. Positions from the frame — headline at 174, strip at
/// 260, body at 362, button at 697.
class MoodRecordScreen extends GetView<MoodRecordController> {
  const MoodRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            ImageConstant.icChevronLeft,
            height: 24.h,
            width: 24.h,
            colorFilter:
                ColorFilter.mode(appTheme.textPrimary, BlendMode.srcIn),
          ),
          onPressed: Get.back,
        ),
        title: const Text('Mood Records'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 63.h),
              Obx(
                () => Text(
                  controller.headline,
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.recordCelebration,
                ),
              ),
              SizedBox(height: 32.h),
              Obx(
                () {
                  // Read the list's contents, not the RxList object: handing
                  // the object straight to a List parameter registers no
                  // observable, and Obx throws when it tracks nothing.
                  final completed = controller.completed.toList();
                  return StreakStrip(
                    labels: controller.labels,
                    completed: completed,
                    todayIndex: controller.todayIndex,
                  );
                },
              ),
              SizedBox(height: 41.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 35.h),
                child: Text(
                  controller.body,
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.recordCelebrationBody,
                ),
              ),
              const Spacer(),
              CustomGhostButton(
                text: 'Return home',
                onPressed: controller.returnHome,
              ),
              SizedBox(height: 43.h),
            ],
          ),
        ),
      ),
    );
  }
}
