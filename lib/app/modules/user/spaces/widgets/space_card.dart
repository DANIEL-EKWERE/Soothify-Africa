import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/wellness_space.dart';

/// A grey pill under a studio's name — "Reformer Pilates", "Mat Pilates".
/// 22 tall, 16 radius, `#EEF1F5` under `#717C87` type.
class SpaceTag extends StatelessWidget {
  const SpaceTag(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    // A Container given an `alignment` expands to the largest size its parent
    // allows — which stretched these pills across the whole card instead of
    // hugging their labels. Centring the text inside a Column that shrinks to
    // its child keeps the pill the width of its word.
    return Container(
      height: 22.v,
      padding: EdgeInsets.symmetric(horizontal: 8.h),
      decoration: BoxDecoration(
        color: appTheme.spaceTag,
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(label, style: CustomTextStyles.spaceTag)],
      ),
    );
  }
}

/// "Get Directions", in brand blue with a pin ahead of it.
class SpaceDirections extends StatelessWidget {
  const SpaceDirections({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.near_me_outlined, size: 16.h, color: appTheme.soothifyBlue),
          SizedBox(width: 8.h),
          Text('Get Directions', style: CustomTextStyles.spaceDirections),
        ],
      ),
    );
  }
}

/// One studio in the list — Figma `282:25161`, a 342x266 card at an 8 radius
/// with a 342x130 photograph across the top.
///
/// Measured from the card's own origin: the photo fills 0..130, the name sits
/// at 146, the area at 173, the tags at 196 and the footer at 234, with the
/// distance pill right-aligned at 187.
class SpaceCard extends StatelessWidget {
  const SpaceCard({super.key, required this.space, this.onTap});

  final WellnessSpace space;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomImageView(
              imagePath: space.photo,
              height: 130.v,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8.h, 16.v, 8.h, 16.v),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(space.name, style: CustomTextStyles.spaceName),
                  SizedBox(height: 8.v),
                  Text(space.area, style: CustomTextStyles.spaceArea),
                  SizedBox(height: 9.v),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8.h,
                          runSpacing: 6.v,
                          children: [
                            for (final tag in space.tags) SpaceTag(tag),
                          ],
                        ),
                      ),
                      _DistancePill(label: space.distanceLabel),
                    ],
                  ),
                  SizedBox(height: 16.v),
                  SpaceDirections(onTap: onTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "2.4 km away" — 22 tall on the brand's palest blue.
class _DistancePill extends StatelessWidget {
  const _DistancePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22.v,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 8.h),
      decoration: BoxDecoration(
        color: appTheme.policyPanel,
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Text(label, style: CustomTextStyles.spaceDistance),
    );
  }
}
