import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/discussion.dart';

/// The forum's post card — Figma `Frame 1618868780`, 344x285.
///
/// Shared because the frame is one component used twice: in the forum list
/// (135:5052) and at the head of a thread (135:6218). Keeping one widget is
/// what guarantees the two stay identical.
class DiscussionCard extends StatelessWidget {
  const DiscussionCard({
    super.key,
    required this.discussion,
    required this.now,
    this.onTap,
  });

  final Discussion discussion;
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.h),
      child: Container(
        padding: EdgeInsets.fromLTRB(16.h, 31.v, 16.h, 20.v),
        decoration: BoxDecoration(
          // Fixed brand blue in both themes: the card carries white type, so
          // following a themed surface would strand it.
          color: appTheme.soothifyBlue,
          borderRadius: BorderRadius.circular(16.h),
          border: Border.all(color: appTheme.topicChipBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                    size: 32.h,
                    color: appTheme.textPrimary,
                  ),
                ),
                SizedBox(width: 14.h),
                Expanded(
                  child: Text(
                    discussion.title,
                    textAlign: TextAlign.center,
                    style: CustomTextStyles.discussionTitle,
                  ),
                ),
                Icon(Icons.more_horiz, size: 21.h, color: appTheme.onPrimary),
              ],
            ),
            SizedBox(height: 14.v),
            Text(discussion.body, style: CustomTextStyles.discussionBody),
            SizedBox(height: 14.v),
            Text(discussion.author, style: CustomTextStyles.discussionBody),
            SizedBox(height: 12.v),
            Row(
              children: [
                _Counter(
                  asset: ImageConstant.icHeart,
                  value: discussion.likes,
                ),
                SizedBox(width: 28.h),
                _Counter(
                  icon: Icons.chat_bubble_outline,
                  value: discussion.comments,
                ),
                SizedBox(width: 28.h),
                _Counter(icon: Icons.ios_share, value: discussion.shares),
                const Spacer(),
                Text(
                  discussion.relativeTime(now),
                  style: CustomTextStyles.discussionMeta,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({this.icon, this.asset, required this.value});

  /// Exactly one of these is set: [asset] where Figma exported the glyph,
  /// [icon] where it did not and Material still stands in.
  final IconData? icon;
  final String? asset;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (asset != null)
          CustomImageView(
            imagePath: asset,
            height: 17.h,
            width: 17.h,
            color: appTheme.onPrimary,
          )
        else
          Icon(icon, size: 17.h, color: appTheme.onPrimary),
        SizedBox(width: 6.h),
        Text('$value', style: CustomTextStyles.discussionMeta),
      ],
    );
  }
}
