import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/gradient_text.dart';
import '../widgets/discussion_card.dart';
import 'controller/forum_controller.dart';

/// The forum list — Figma "Join discussion" (135:5035).
///
/// Cards are the brand blue with white type; the two actions sit in a row at
/// the foot rather than pinned, matching the frame's 1769-tall scroll.
class ForumScreen extends GetView<ForumController> {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.h, 14.v, 20.h, 32.v),
            children: [
              _BackRow(),
              SizedBox(height: 50.v),
              Padding(
                padding: EdgeInsets.only(left: 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientText(
                      'Recent Discussions',
                      gradient: appTheme.authHeaderGradient,
                      style: CustomTextStyles.communityHeading,
                    ),
                    SizedBox(height: 16.v),
                    GradientText(
                      'See the latest community conversations',
                      gradient: appTheme.authHeaderGradient,
                      style: CustomTextStyles.sectionTitle,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 35.v),
              Obx(
                () => Column(
                  children: [
                    for (final d in controller.discussions) ...[
                      DiscussionCard(
                        discussion: d,
                        now: controller.now,
                        onTap: () => controller.openThread(d),
                      ),
                      SizedBox(height: 32.v),
                    ],
                  ],
                ),
              ),
              const _ForumActions(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackRow extends StatelessWidget {
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
            color: appTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ForumActions extends StatelessWidget {
  const _ForumActions();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForumController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: controller.loadMore,
          borderRadius: BorderRadius.circular(16.h),
          child: Container(
            height: 39.v,
            padding: EdgeInsets.symmetric(horizontal: 25.h),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.h),
              border: Border.all(color: appTheme.soothifyBlue),
            ),
            child: Text('Load more', style: CustomTextStyles.forumAction),
          ),
        ),
        InkWell(
          onTap: controller.startDiscussion,
          borderRadius: BorderRadius.circular(16.h),
          child: Container(
            height: 39.v,
            padding: EdgeInsets.symmetric(horizontal: 9.h),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: appTheme.soothifyBlue,
              borderRadius: BorderRadius.circular(16.h),
            ),
            child: Text(
              'Start Discussion',
              style: CustomTextStyles.forumAction.copyWith(
                color: appTheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
