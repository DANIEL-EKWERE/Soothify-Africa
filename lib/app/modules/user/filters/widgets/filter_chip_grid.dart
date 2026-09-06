import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/media_filter.dart';
import '../controller/filters_controller.dart';

/// A group's chips, two to a row — the layout every chip group in the filter
/// frames uses.
///
/// 162x37 pills with a 20 radius, 18 apart across and 8 down. The trailing
/// odd cell carries the group's "See More..." link, which is where the frames
/// put it whenever a group has an odd number of chips.
class FilterChipGrid extends StatelessWidget {
  const FilterChipGrid({super.key, required this.group});

  final FilterGroup group;

  static const chipHeight = 37.0;
  static const rowGap = 8.0;
  static const columnGap = 18.0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FiltersController>();
    final options = group.options;
    // The odd cell at the end is the "See More..." slot in the frames. With
    // an even count — Music — the grid fills exactly and no link is drawn.
    final hasSeeMore = options.length.isOdd;
    final rows = ((options.length + (hasSeeMore ? 1 : 0)) / 2).ceil();

    return Column(
      children: [
        for (var row = 0; row < rows; row++) ...[
          if (row > 0) SizedBox(height: rowGap.v),
          Row(
            children: [
              for (var col = 0; col < 2; col++) ...[
                if (col > 0) SizedBox(width: columnGap.h),
                Expanded(
                  child: switch (row * 2 + col) {
                    final i when i < options.length => Obx(
                      () => _Chip(
                        label: options[i],
                        selected: controller.isSelected(group, options[i]),
                        onTap: () => controller.toggle(group, options[i]),
                      ),
                    ),
                    _ when hasSeeMore => const _SeeMore(),
                    _ => SizedBox(height: chipHeight.v),
                  },
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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
      borderRadius: BorderRadius.circular(20.h),
      child: Container(
        height: FilterChipGrid.chipHeight.v,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 8.h),
        decoration: BoxDecoration(
          // The frames draw only the unselected chip, which already carries a
          // hairline — so selection fills the pill rather than outlining it,
          // the way the primary action button reads elsewhere in the app.
          color: selected ? appTheme.actionFill : appTheme.filterChipFill,
          borderRadius: BorderRadius.circular(20.h),
          border: Border.all(
            color: selected ? appTheme.actionFill : appTheme.filterChipBorder,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: selected
              ? CustomTextStyles.filterChipLabelSelected
              : CustomTextStyles.filterChipLabel,
        ),
      ),
    );
  }
}

/// The frames close an odd group with this link, aligned to the column's left
/// edge and centred against the row.
///
/// There is nothing behind it yet: the frames show seven teachers and seven
/// body parts with no longer list drawn anywhere, so tapping says as much
/// rather than expanding to the same seven.
class _SeeMore extends StatelessWidget {
  const _SeeMore();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: FilterChipGrid.chipHeight.v,
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () => AppFeedback.info('That is the full list for now.'),
          child: Text('See More...', style: CustomTextStyles.filterSeeMore),
        ),
      ),
    );
  }
}
