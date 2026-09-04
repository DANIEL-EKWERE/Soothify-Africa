import 'package:flutter/material.dart';

import '../../../../../core/app_export.dart';

/// The white pill naming a category, sitting over cover art.
class CategoryPill extends StatelessWidget {
  const CategoryPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 11.h,
      padding: EdgeInsets.symmetric(horizontal: 6.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(10.h),
      ),
      child: Text(label, style: CustomTextStyles.pillLabel),
    );
  }
}

/// A dark pill carrying an icon and a short value — duration, or a rating.
class DarkPill extends StatelessWidget {
  const DarkPill({super.key, required this.asset, required this.label});

  /// The exported glyph — play or star, from the card component.
  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10.h,
      padding: EdgeInsets.symmetric(horizontal: 3.h),
      decoration: BoxDecoration(
        color: appTheme.pillDark,
        borderRadius: BorderRadius.circular(10.h),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomImageView(
            imagePath: asset,
            height: 6.h,
            width: 6.h,
            color: appTheme.onPrimary,
          ),
          SizedBox(width: 3.h),
          Text(label, style: CustomTextStyles.pillLabelOnDark),
        ],
      ),
    );
  }
}

/// Renders an item's cover art, falling back to a sized block when there is
/// none — so the layout is right either way.
class ArtworkPlaceholder extends StatelessWidget {
  const ArtworkPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.radius = 0,
    this.assetPath,
  });

  final double width;
  final double height;
  final double radius;

  /// The exported cover, when the item has one. Null or missing falls back to
  /// the flat block, so a item without art still lays out at the right size.
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    final flat = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: appTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
    final path = assetPath;
    if (path == null || path.isEmpty) return flat;

    // The block stays underneath rather than being replaced: an asset that is
    // still decoding, missing, or unloaded (as in a widget test) then leaves
    // the card looking as it did before instead of blank.
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: appTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}
