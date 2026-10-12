import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// The filter pill used above a list — "All / Sessions / What's new" on the
/// notification feed, and the category row on Spaces Around Me.
///
/// One widget for both, because the design draws one control. They had drifted
/// into two: the feed's was a 20-tall transparent chip, Spaces' a 34-tall one,
/// and only Spaces filled its unselected state.
///
/// Measured off the frames at 2x: a 30-tall pill, fully rounded, 14 of padding
/// either side and 8 between. Selected is solid brand blue with white words;
/// unselected is white inside a hairline. The words are bold in both states —
/// they do not get lighter when deselected, they only change colour.
class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.h),
      // No `alignment` on the box: with one set it expands to the row it sits
      // in instead of hugging its label.
      child: Container(
        height: 30.v,
        padding: EdgeInsets.symmetric(horizontal: 14.h),
        decoration: BoxDecoration(
          color: selected ? appTheme.soothifyBlue : appTheme.surface,
          borderRadius: BorderRadius.circular(15.h),
          // 4% black, never the body ink — a white pill takes a hairline.
          border: selected ? null : Border.all(color: appTheme.cardRim),
        ),
        child: Center(
          widthFactor: 1,
          child: Text(
            label,
            maxLines: 1,
            style: selected
                ? CustomTextStyles.filterPillSelected
                : CustomTextStyles.filterPill,
          ),
        ),
      ),
    );
  }
}
