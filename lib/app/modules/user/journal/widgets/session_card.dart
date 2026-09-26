import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/expert_recommendation.dart';

/// One session on the Journal's Expert Recommendation tab — Figma
/// `259:60761`.
///
/// Measured: the card 342 wide and 231.8 tall, a 44 avatar inset 13, the name
/// at 13 from the card top with the service at 40 and the date at 64, a "New"
/// pill 39x22 at the top right, the note panel inset 13 and 58 tall from 96,
/// and the action row 56.8 tall from 162 with a 36.8 disc at its left.
class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.recommendation,
    required this.onTap,
  });

  final ExpertRecommendation recommendation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(13.h),
        decoration: BoxDecoration(
          color: appTheme.surface,
          border: Border.all(color: appTheme.rowBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: CustomImageView(
                    imagePath: recommendation.avatarAsset,
                    height: 44.h,
                    width: 44.h,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 8.h),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.expertName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CustomTextStyles.sessionCardName,
                      ),
                      SizedBox(height: 8.v),
                      Text(
                        recommendation.sessionLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CustomTextStyles.sessionCardMeta,
                      ),
                      SizedBox(height: 8.v),
                      Text(
                        DateFormat('MMM d, yyyy')
                            .format(recommendation.recordedAt),
                        style: CustomTextStyles.sessionCardMeta,
                      ),
                    ],
                  ),
                ),
                if (recommendation.isNew) const _NewBadge(),
              ],
            ),
            SizedBox(height: 14.v),
            _NotePanel(note: recommendation.note),
            SizedBox(height: 8.v),
            _ActionRow(
              content: recommendation.content,
              sessionLabel: recommendation.sessionLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 39.h,
      height: 22.v,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // The frame fills the pill with the unread red at 20%, and sets the
        // word in the same red at full strength.
        color: appTheme.unreadDot.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Text('New', style: CustomTextStyles.expertNewBadge),
    );
  }
}

class _NotePanel extends StatelessWidget {
  const _NotePanel({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58.v,
      padding: EdgeInsets.symmetric(horizontal: 11.h),
      decoration: BoxDecoration(
        color: appTheme.policyPanel,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.rowBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_square,
            size: 13.5.h,
            color: appTheme.soothifyBlue,
          ),
          SizedBox(width: 9.h),
          Expanded(
            child: Text(
              note,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: CustomTextStyles.sessionCardNote,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Watch video" / "Read Article" / "Listen", over the session it came from.
class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.content, required this.sessionLabel});

  final ExpertContent content;
  final String sessionLabel;

  IconData get _glyph => switch (content.kind) {
        ExpertContentKind.video => Icons.play_arrow_rounded,
        ExpertContentKind.article => Icons.article_outlined,
        ExpertContentKind.audio => Icons.headphones_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.8.v,
      padding: EdgeInsets.symmetric(horizontal: 9.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.rowBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36.8.h,
            height: 36.8.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: appTheme.policyPanel,
              shape: BoxShape.circle,
            ),
            child: Icon(_glyph, size: 18.h, color: appTheme.soothifyBlue),
          ),
          SizedBox(width: 8.h),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(content.kind.action,
                    style: CustomTextStyles.sessionCardAction),
                SizedBox(height: 4.v),
                Text(
                  sessionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyles.sessionCardMeta,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
