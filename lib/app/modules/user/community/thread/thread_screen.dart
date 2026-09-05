import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/comment.dart';
import '../widgets/discussion_card.dart';
import 'controller/thread_controller.dart';

/// A discussion thread — Figma "On going discussion comments" (135:6190).
///
/// Geometry is measured. Type and colour for the comment rows are inherited
/// from the identical components elsewhere in the file — the post card is the
/// same `Frame 1618868780` the forum list uses, and the message bar is the
/// Journal composer's — because the design-context call that carries fills and
/// fonts was rate-limited. The two genuinely unmeasured choices are the
/// comment body colour (taken as on-background text, like every other
/// on-background run of copy here) and the Reply link colour (taken as the
/// brand blue, like "See All" and "Load more").
class ThreadScreen extends GetView<ThreadController> {
  const ThreadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.load,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(24.h, 22.v, 24.h, 16.v),
                  children: [
                    Text(
                      'Comments',
                      style: CustomTextStyles.communityHeading,
                    ),
                    SizedBox(height: 11.v),
                    DiscussionCard(
                      discussion: controller.discussion,
                      now: controller.now,
                    ),
                    SizedBox(height: 30.v),
                    Obx(() => Column(
                          children: [
                            for (final c in controller.comments) ...[
                              _CommentRow(comment: c, now: controller.now),
                              SizedBox(height: 26.v),
                            ],
                          ],
                        )),
                  ],
                ),
              ),
            ),
            const _MessageBar(),
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
    return Padding(
      padding: EdgeInsets.fromLTRB(26.h, 16.v, 26.h, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          CustomImageView(
            imagePath: ImageConstant.icMenu,
            height: 24.h,
            width: 24.h,
            color: appTheme.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({required this.comment, required this.now});

  final Comment comment;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThreadController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(
              child: CustomImageView(
                imagePath: ImageConstant.imgMemberAvatar,
                height: 44.h,
                width: 44.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 5.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          comment.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CustomTextStyles.commentAuthor,
                        ),
                      ),
                      Text(
                        comment.relativeTime(now),
                        style: CustomTextStyles.commentMeta,
                      ),
                    ],
                  ),
                  SizedBox(height: 5.v),
                  Text(comment.body, style: CustomTextStyles.commentBody),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 4.v),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () => controller.reply(comment),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Reply', style: CustomTextStyles.replyLink),
                SizedBox(width: 4.h),
                CustomImageView(
                  imagePath: ImageConstant.icReply,
                  height: 16.h,
                  width: 16.h,
                  color: appTheme.soothifyBlue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBar extends StatelessWidget {
  const _MessageBar();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThreadController>();
    return Padding(
      padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 16.v),
      child: Container(
        height: 40.v,
        padding: EdgeInsets.only(left: 11.h, right: 8.h),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(20.h),
          border: Border.all(color: appTheme.searchBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.message,
                style: CustomTextStyles.commentBody,
                decoration: InputDecoration(
                  hintText: 'Type in your message',
                  hintStyle: CustomTextStyles.searchHint,
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            Obx(() => InkWell(
                  onTap: controller.canSend.value ? controller.send : null,
                  child: CustomImageView(
                    imagePath: ImageConstant.icSend,
                    height: 24.h,
                    width: 24.h,
                    color: controller.canSend.value
                        ? appTheme.actionFill
                        : appTheme.navInactive,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
