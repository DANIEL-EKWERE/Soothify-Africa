import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/community_topic.dart';
import 'controller/community_tab_controller.dart';
import 'widgets/community_steps.dart';

/// Community — Figma "Cpommunity topics" (135:4996).
///
/// Identity block, then a two-column grid of topic chips, then Proceed. The
/// frame's own bottom navigation at y=770 is skipped; the shell supplies it.
///
/// Chip artwork was not exported, so each chip shows a neutral placeholder
/// square at the design's 30x30 rather than its illustration.
class CommunityTab extends GetView<CommunityTabController> {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      // All three steps carry the bottom navigation in the design, so they are
      // stages inside the tab rather than pushed routes.
      body: SafeArea(
        child: Obx(
          () => switch (controller.stage.value) {
            CommunityStage.welcome => const CommunityWelcomeStep(),
            CommunityStage.username => const CommunityUsernameStep(),
            CommunityStage.topics => const _TopicsStep(),
          },
        ),
      ),
    );
  }
}

class _TopicsStep extends StatelessWidget {
  const _TopicsStep();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(24.h, 98.v, 24.h, 32.v),
      children: [
        const _Identity(),
        SizedBox(height: 39.v),
        Padding(
          padding: EdgeInsets.only(left: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Topics', style: CustomTextStyles.communityHeading),
              SizedBox(height: 16.v),
              Text(
                'Find conversations by topics that interest you',
                style: CustomTextStyles.communityBody,
              ),
            ],
          ),
        ),
        SizedBox(height: 32.v),
        const _TopicGrid(),
        SizedBox(height: 88.v),
        const _ProceedButton(),
      ],
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunityTabController>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 68.h,
          height: 68.h,
          decoration: BoxDecoration(
            color: appTheme.avatarBacking,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.person_outline,
            size: 34.h,
            color: appTheme.textPrimary,
          ),
        ),
        SizedBox(width: 24.h),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 13.v),
              Text(
                controller.displayName,
                style: CustomTextStyles.communityHeading,
              ),
              SizedBox(height: 5.v),
              Row(
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.icLocation,
                    height: 16.h,
                    width: 16.h,
                    color: appTheme.textSecondary,
                  ),
                  SizedBox(width: 6.h),
                  Text(
                    controller.location,
                    style: CustomTextStyles.communityBody,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopicGrid extends StatelessWidget {
  const _TopicGrid();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunityTabController>();
    return Obx(() {
      // Rebuilt as a whole when the set changes: reading `selected` here is
      // what registers the observable, and each chip only reads through
      // isSelected, which would not register on its own.
      final chosen = controller.selected.toSet();
      return Wrap(
        spacing: 16.h,
        runSpacing: 8.v,
        children: [
          for (final topic in controller.topics)
            _TopicChip(
              topic: topic,
              selected: chosen.contains(topic.id),
              onTap: () => controller.toggle(topic),
            ),
        ],
      );
    });
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.topic,
    required this.selected,
    required this.onTap,
  });

  final CommunityTopic topic;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.h),
      child: Container(
        width: 163.h,
        height: 48.v,
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(16.h),
          border: Border.all(
            color: selected ? appTheme.soothifyBlue : appTheme.topicChipBorder,
          ),
        ),
        child: Row(
          children: [
            if (topic.isOthers)
              Icon(Icons.more_horiz, size: 20.h, color: appTheme.textSecondary)
            else
              Container(
                width: 30.h,
                height: 30.h,
                decoration: BoxDecoration(
                  color: appTheme.avatarBacking,
                  borderRadius: BorderRadius.circular(6.h),
                ),
              ),
            SizedBox(width: 8.h),
            Flexible(
              child: Text(
                topic.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStyles.topicChip,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProceedButton extends StatelessWidget {
  const _ProceedButton();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunityTabController>();
    return Obx(() {
      final enabled = controller.canProceed;
      return InkWell(
        onTap: enabled ? controller.proceed : null,
        borderRadius: BorderRadius.circular(8.h),
        child: Container(
          height: 52.v,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? appTheme.actionFill : appTheme.actionFillDisabled,
            borderRadius: BorderRadius.circular(8.h),
          ),
          child: Text(
            'Proceed',
            style: CustomTextStyles.subscribeLabel.copyWith(fontSize: 18.fSize),
          ),
        ),
      );
    });
  }
}
