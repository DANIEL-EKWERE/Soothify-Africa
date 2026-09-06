import 'package:flutter/material.dart';

import '../../../../../core/app_export.dart';
import '../../../../../data/models/media_item.dart';
import 'content_pills.dart';

/// A "Recommended for you" row — 342x122, 1px outline, 12px radius.
///
/// The cover carries three pills stacked over it (category, duration, rating)
/// and a right-hand rail holding the favourite heart above a premium lock.
class RecommendedCard extends StatelessWidget {
  const RecommendedCard({super.key, required this.item, this.onTap});

  final MediaItem item;
  final VoidCallback? onTap;

  String get _duration {
    final m = item.duration.inMinutes.toString().padLeft(2, '0');
    final s = (item.duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 122.h,
        padding: EdgeInsets.symmetric(horizontal: 14.h),
        decoration: BoxDecoration(
          color: appTheme.surface,
          // 4% ink, not solid. The JSON export reports this stroke as plain
          // #263238 because it drops opacity; the same colour reads as
          // opacity 0.04 through the REST API on the KYC rows, and at full
          // strength it draws a black box round every card.
          border: Border.all(color: appTheme.optionBorder),
          borderRadius: BorderRadius.circular(12.h),
        ),
        child: Row(
          children: [
            _Cover(item: item, duration: _duration),
            SizedBox(width: 16.h),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.subtitle,
                      style: CustomTextStyles.itemCategory,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 5.h),
                  Text(item.title,
                      style: CustomTextStyles.itemTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 5.h),
                  Text(item.practitionerName,
                      style: CustomTextStyles.itemAuthor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            SizedBox(width: 16.h),
            const _SideRail(),
          ],
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.item, required this.duration});

  final MediaItem item;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92.h,
      height: 92.h,
      child: Stack(
        children: [
          ArtworkPlaceholder(
            width: 92.h,
            height: 92.h,
            radius: 6.h,
            assetPath: item.coverAsset,
          ),
          Positioned(
            top: 6.h,
            left: 6.h,
            child: CategoryPill(label: item.tag),
          ),
          Positioned(
            bottom: 6.h,
            left: 6.h,
            child: DarkPill(asset: ImageConstant.icPlay, label: duration),
          ),
          Positioned(
            bottom: 6.h,
            right: 6.h,
            child: DarkPill(asset: ImageConstant.icStar, label: '4.6'),
          ),
        ],
      ),
    );
  }
}

/// Heart above, lock below, 45 apart — the design's 29x94 rail.
class _SideRail extends StatelessWidget {
  const _SideRail();

  @override
  Widget build(BuildContext context) {
    // 29x94 with a 45 gap, measured — not spread across the card's full
    // height, which pushed the heart and padlock to the outer edges.
    return SizedBox(
      width: 29.h,
      height: 94.v,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomImageView(
            imagePath: ImageConstant.icHeart,
            height: 20.h,
            width: 20.h,
            color: appTheme.textPrimary,
          ),
          // The design draws the padlock on every card — it is part of the
          // card component, not a per-item state. If locking should follow
          // MediaItem.isFree instead, this is the line to gate.
            Container(
              width: 29.h,
              height: 29.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appTheme.lockCircle,
                shape: BoxShape.circle,
              ),
              child: CustomImageView(
                imagePath: ImageConstant.icLock,
                height: 15.h,
                width: 15.h,
                color: appTheme.lockGlyph,
              ),
            ),
        ],
      ),
    );
  }
}
