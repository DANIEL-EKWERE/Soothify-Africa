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

  /// The design clamps the body to three lines.
  static const int _bodyLines = 3;

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
                ClipOval(
                  child: CustomImageView(
                    imagePath: ImageConstant.imgMemberAvatar,
                    height: 68.h,
                    width: 68.h,
                    fit: BoxFit.cover,
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
                CustomImageView(
                  imagePath: ImageConstant.icMore,
                  height: 4.h,
                  width: 21.h,
                  color: appTheme.onPrimary,
                ),
              ],
            ),
            SizedBox(height: 14.v),
            // Body and footer are built in one pass: whether the clamped copy
            // overflows decides the "Read more" link, and the frame shows that
            // link only on the cards whose text is cut. Measuring here avoids
            // holding the result as state between two separate builds.
            LayoutBuilder(
              builder: (context, constraints) {
                final style = CustomTextStyles.discussionBody;
                final painter = TextPainter(
                  text: TextSpan(text: discussion.body, style: style),
                  maxLines: _bodyLines,
                  textDirection: Directionality.of(context),
                )..layout(maxWidth: constraints.maxWidth);
                final cut = painter.didExceedMaxLines;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      discussion.body,
                      maxLines: _bodyLines,
                      overflow: TextOverflow.ellipsis,
                      style: style,
                    ),
                    SizedBox(height: 14.v),
                    Text(
                      discussion.author,
                      style: CustomTextStyles.discussionBody,
                    ),
                    SizedBox(height: 12.v),
                    Row(
                      children: [
                        if (cut) ...[
                          Text(
                            'Read more',
                            style: CustomTextStyles.discussionMeta,
                          ),
                          SizedBox(width: 28.h),
                        ],
                        _Counter(
                          asset: ImageConstant.icLike,
                          value: discussion.likes,
                        ),
                        SizedBox(width: 28.h),
                        _Counter(
                          asset: ImageConstant.icComment,
                          value: discussion.comments,
                        ),
                        SizedBox(width: 28.h),
                        _Counter(
                          asset: ImageConstant.icShare,
                          value: discussion.shares,
                        ),
                        const Spacer(),
                        Text(
                          discussion.relativeTime(now),
                          style: CustomTextStyles.discussionMeta,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.asset, required this.value});

  final String asset;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomImageView(
          imagePath: asset,
          height: 17.h,
          width: 17.h,
          color: appTheme.onPrimary,
        ),
        SizedBox(width: 6.h),
        Text('$value', style: CustomTextStyles.discussionMeta),
      ],
    );
  }
}
