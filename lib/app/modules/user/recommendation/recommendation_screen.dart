import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_export.dart';
import '../../../widgets/skeleton.dart';
import '../shell/tabs/widgets/recommended_card.dart';
import 'controller/recommendation_controller.dart';

/// Recommendation — Figma `135:1372`.
///
/// The same card Home uses, listed in full: heading at 120, first card at 157,
/// then 342x122 rows 8 apart.
///
/// The design titles this screen "Mood Checker", which reads oddly on its own
/// but is what the frame says — it is reached from the mood check-in flow.
class RecommendationScreen extends GetView<RecommendationController> {
  const RecommendationScreen({super.key});

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
        title: const Text('Mood Checker'),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            // The page it is about to be, rather than a spinner in the
            // middle of nothing: the heading is already known, and the
            // cards land in the shape the skeletons held.
            return ListView(
              padding: EdgeInsets.fromLTRB(24.h, 32.h, 24.h, 32.h),
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Text('Recommended for you',
                      style: CustomTextStyles.sectionTitle),
                ),
                const SkeletonShimmer(
                  child: Column(
                    children: [
                      Skeleton(width: 342, height: 122),
                      SizedBox(height: 8),
                      Skeleton(width: 342, height: 122),
                      SizedBox(height: 8),
                      Skeleton(width: 342, height: 122),
                    ],
                  ),
                ),
              ],
            );
          }
          return RefreshIndicator(
            onRefresh: controller.reload,
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(24.h, 32.h, 24.h, 32.h),
              itemCount: controller.items.length + 1,
              separatorBuilder: (_, _) => SizedBox(height: 8.h),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Text('Recommended for you',
                        style: CustomTextStyles.sectionTitle),
                  );
                }
                return RecommendedCard(item: controller.items[i - 1]);
              },
            ),
          );
        }),
      ),
    );
  }
}
