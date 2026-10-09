import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/skeleton.dart';
import '../shell/tabs/widgets/recommended_card.dart';
import 'controller/mood_recommendation_controller.dart';

/// What the app offers back after a mood check-in — Figma
/// `Recommendation | <mood>` (page 124:2), ten frames that differ only in
/// their opening line.
///
/// Measured below the status bar: header 22, headline 77.5 (three lines at a
/// 21 pitch), first card 167, cards 93 tall at a 130 pitch.
class MoodRecommendationScreen
    extends GetView<MoodRecommendationController> {
  const MoodRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 22.v),
            const _Header(),
            SizedBox(height: 41.5.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: Text(
                controller.intro,
                style: CustomTextStyles.moodRecommendationIntro,
              ),
            ),
            SizedBox(height: 40.v),
            Expanded(
              child: Obx(() {
                if (controller.items.isEmpty && controller.isLoading.value) {
                  return SkeletonShimmer(
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 32.v),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      separatorBuilder: (_, _) => SizedBox(height: 37.v),
                      itemBuilder: (_, _) =>
                          const Skeleton(width: 342, height: 122),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 32.v),
                  itemCount: controller.items.length,
                  separatorBuilder: (_, _) => SizedBox(height: 8.v),
                  itemBuilder: (context, i) => ContentReveal(
                    delay: Duration(milliseconds: 70 * i),
                    child: RecommendedCard(
                      item: controller.items[i],
                      onTap: () => controller.open(controller.items[i]),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MoodRecommendationController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Row(
        children: [
          InkWell(
            // Forward, not back: the mood is already saved, and the day's
            // check-in is what follows this screen.
            onTap: controller.done,
            child: CustomImageView(
              imagePath: ImageConstant.icBack,
              height: 18.h,
              width: 18.h,
              color: appTheme.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              'Mood Checker',
              textAlign: TextAlign.center,
              style: CustomTextStyles.appBarTitle,
            ),
          ),
          SizedBox(width: 18.h),
        ],
      ),
    );
  }
}
