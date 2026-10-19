import 'package:flutter/material.dart';

import '../core/app_export.dart';
import '../data/models/expert_recommendation.dart';

/// The piece of content an expert points a client at — Figma "Journal"
/// (`259:60842`) and "Session notes | After session" (`259:59854`), which
/// draw the same card.
///
/// A cover, the kind in blue beneath it, the title, the duration line, then
/// the action. The journal lays a play disc over the cover; the notes frame
/// does not, which is what [showPlayOverlay] is for.
class ExpertContentCard extends StatelessWidget {
  const ExpertContentCard({
    super.key,
    required this.content,
    required this.onOpen,
    this.showPlayOverlay = true,
    this.coverHeight = 148,
    this.actionLabel,
  });

  final ExpertContent content;
  final VoidCallback onOpen;
  final bool showPlayOverlay;

  /// 148 in the journal; the notes frame crops it to 116.
  final double coverHeight;

  /// Overrides the kind's own wording — the two frames capitalise it
  /// differently ("Watch video" / "Watch Video").
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(17.h),
      decoration: AppDecoration.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onOpen,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.h),
                  child: CustomImageView(
                    imagePath: content.cover,
                    height: coverHeight.v,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (showPlayOverlay)
                  Container(
                    width: 46.h,
                    height: 46.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: appTheme.onPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 26.h,
                      color: appTheme.soothifyBlue,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 15.v),
          Row(
            children: [
              Icon(
                Icons.play_circle_outline,
                size: 16.h,
                color: appTheme.soothifyBlue,
              ),
              SizedBox(width: 6.h),
              Text(content.kind.label,
                  style: CustomTextStyles.expertContentKind),
            ],
          ),
          SizedBox(height: 11.v),
          Text(content.title, style: CustomTextStyles.expertContentTitle),
          SizedBox(height: 13.v),
          Text(content.meta, style: CustomTextStyles.expertMeta),
          SizedBox(height: 19.5.v),
          GestureDetector(
            onTap: onOpen,
            child: Container(
              height: 39.v,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appTheme.soothifyBlue,
                borderRadius: BorderRadius.circular(8.h),
              ),
              child: Text(
                actionLabel ?? content.kind.action,
                style: CustomTextStyles.expertContentTitle
                    .copyWith(color: appTheme.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
