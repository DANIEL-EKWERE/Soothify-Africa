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
  const DarkPill({super.key, required this.icon, required this.label});

  final IconData icon;
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
          Icon(icon, size: 6.h, color: appTheme.onPrimary),
          SizedBox(width: 3.h),
          Text(label, style: CustomTextStyles.pillLabelOnDark),
        ],
      ),
    );
  }
}

/// Stands in for artwork not yet exported from Figma.
///
/// Sized exactly as the design specifies, so the layout is already right and
/// only the fill is missing.
class ArtworkPlaceholder extends StatelessWidget {
  const ArtworkPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.radius = 0,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: appTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
