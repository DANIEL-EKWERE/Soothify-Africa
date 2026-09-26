import 'package:flutter/material.dart';

import '../core/app_export.dart';
import 'filter_glyph.dart';

/// The search field and filter glyph that sit above a shelf of content.
///
/// The same row on the two libraries (`135:11744`, `135:20551`), the Videos
/// screen (`259:60948`) and its See All grid (`259:61062`) — 48 tall with a
/// 24 radius, the field 289 wide, then 28 of gap and the glyph.
///
/// Extracted so the four cannot drift: the glyph's badge, in particular, is
/// the only sign anywhere that a filter is on.
class ContentSearchRow extends StatelessWidget {
  const ContentSearchRow({
    super.key,
    required this.hint,
    required this.filterCount,
    required this.onSearch,
    required this.onFilters,
  });

  final String hint;

  /// How many filters are applied; zero hides the badge.
  final int filterCount;

  final VoidCallback onSearch;
  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onSearch,
            borderRadius: BorderRadius.circular(24.h),
            child: Container(
              height: 48.v,
              padding: EdgeInsets.symmetric(horizontal: 15.h),
              decoration: BoxDecoration(
                color: appTheme.surface,
                borderRadius: BorderRadius.circular(24.h),
              ),
              child: Row(
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.icSearch,
                    height: 18.h,
                    width: 18.h,
                    color: appTheme.textPrimary,
                  ),
                  SizedBox(width: 14.h),
                  Flexible(
                    child: Text(
                      hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyles.searchHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 28.h),
        FilterGlyph(count: filterCount, onTap: onFilters),
      ],
    );
  }
}
