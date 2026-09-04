import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_export.dart';
import 'controller/mood_checker_controller.dart';
import 'widgets/mood_tile.dart';

/// Mood Checker — Figma node 2214:24343.
///
/// Layout from the design: content inset 24 from the left, 142 from the top,
/// 342 wide; 32 between the question and the grid; rows 16 apart with 21
/// between tiles (3 x 100 + 2 x 21 = 342).
class MoodCheckerScreen extends GetView<MoodCheckerController> {
  const MoodCheckerScreen({super.key});

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
            // The exported SVG is black; tint it so it stays visible on the
            // dark palette.
            colorFilter:
                ColorFilter.mode(appTheme.textPrimary, BlendMode.srcIn),
          ),
          onPressed: () =>
              Get.key.currentState?.canPop() == true ? Get.back() : null,
        ),
        title: const Text('Mood Checker'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.h, 32.h, 24.h, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'How do you feel today?',
                textAlign: TextAlign.center,
                style: CustomTextStyles.screenQuestion,
              ),
              SizedBox(height: 32.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.moods.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 21.h,
                  mainAxisSpacing: 16.h,
                  // Tile is a 100 card + 8 gap + ~13 caption line.
                  mainAxisExtent: 121.h,
                ),
                itemBuilder: (context, index) {
                  final mood = controller.moods[index];
                  // Obx goes per tile, not around the grid: itemBuilder runs
                  // lazily, outside the build scope an enclosing Obx would
                  // track, so a grid-level Obx observes nothing and throws.
                  return Obx(
                    () => MoodTile(
                      mood: mood,
                      isSelected: controller.selected.value == mood,
                      onTap: () => controller.select(mood),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
