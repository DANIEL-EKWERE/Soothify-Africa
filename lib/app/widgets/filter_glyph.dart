import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// The filter glyph in a search row, with a count of what is applied.
///
/// The frames draw the glyph bare — they only ever show the unfiltered state.
/// Without the count there is nothing on screen to say a filter is on, which
/// matters here because filtering can empty a shelf.
class FilterGlyph extends StatelessWidget {
  const FilterGlyph({super.key, required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomImageView(
            imagePath: ImageConstant.icFilter,
            height: 19.h,
            width: 25.h,
            color: appTheme.actionFill,
          ),
          if (count > 0)
            Positioned(
              top: -6.v,
              right: -6.h,
              // No `alignment` on the badge's own box: with one set it would
              // expand to the largest size the Stack allows instead of
              // hugging the number.
              child: Container(
                constraints: BoxConstraints(minWidth: 14.h),
                height: 14.h,
                padding: EdgeInsets.symmetric(horizontal: 3.h),
                decoration: BoxDecoration(
                  color: appTheme.actionFill,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(7.h),
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    '$count',
                    style: CustomTextStyles.filterSeeMore.copyWith(
                      color: appTheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
