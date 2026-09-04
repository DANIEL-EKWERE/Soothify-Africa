import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/media_item.dart';

/// A Discovery shelf card — cover art with three overlays.
///
/// The design draws a title pill top-left, and a duration pill and a rating
/// pill along the bottom, all sitting *on* the artwork rather than beneath it.
/// Cover art was not exported, so the artwork is a flat placeholder; the
/// overlays are the design's own.
class DiscoveryCard extends StatelessWidget {
  const DiscoveryCard({
    super.key,
    required this.item,
    required this.onTap,
    this.width = 159,
  });

  final MediaItem item;
  final VoidCallback onTap;
  final double width;

  String get _duration {
    final d = item.duration;
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.h),
      child: SizedBox(
        width: width.h,
        height: 166.v,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: appTheme.avatarBacking,
                  borderRadius: BorderRadius.circular(8.h),
                ),
              ),
            ),
            Positioned(
              left: 8.h,
              top: 8.v,
              // Bounded to the artwork: the pill hugs its title in the design,
              // but an unconstrained one in a Stack sizes to the text and runs
              // off the card — "Awakening sunrise flow" overflowed by 85px.
              right: 8.h,
              child: Align(
                alignment: Alignment.centerLeft,
                // No `alignment` on the Container: setting one makes it
                // expand to the largest allowed size, which stretched the pill
                // across the whole card instead of hugging its title.
                child: Container(
                  height: 18.v,
                  padding: EdgeInsets.symmetric(horizontal: 10.h),
                  decoration: BoxDecoration(
                    color: appTheme.onPrimary,
                    borderRadius: BorderRadius.circular(10.h),
                  ),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyles.pillLabel,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8.h,
              right: 8.h,
              bottom: 8.v,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MetaPill(
                    icon: Icons.play_arrow_rounded,
                    label: _duration,
                  ),
                  // Zero means unrated rather than a genuine 0.0, so the pill
                  // is dropped entirely rather than printing a bad score.
                  if (item.rating > 0)
                    _MetaPill(
                      icon: Icons.star_rounded,
                      label: item.rating.toStringAsFixed(1),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.h, vertical: 1.v),
      decoration: BoxDecoration(
        color: appTheme.pillDark,
        borderRadius: BorderRadius.circular(10.h),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 6.h, color: appTheme.onPrimary),
          SizedBox(width: 2.h),
          Text(label, style: CustomTextStyles.cardMeta),
        ],
      ),
    );
  }
}
