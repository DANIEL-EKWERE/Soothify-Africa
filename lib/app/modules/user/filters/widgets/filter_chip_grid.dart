import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/media_filter.dart';
import '../controller/filters_controller.dart';

/// A group's chips, two to a row — the layout every chip group in the filter
/// frames uses.
///
/// 162x37 pills with a 20 radius, 18 apart across and 8 down. The frames
/// close every odd group with a "See More..." link; it is dropped here, so
/// an odd group simply leaves its last cell empty.
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
    final rows = (options.length / 2).ceil();

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
          // Selection swaps the hairline for a blue one and changes nothing
          // else — the fill and the label stay put, as the selected variants
          // of More Filters (`259:30410`) and Style (`259:30732`) draw it.
          color: appTheme.filterChipFill,
          borderRadius: BorderRadius.circular(20.h),
          border: Border.all(
            color: selected
                ? appTheme.soothifyBlue
                : appTheme.filterChipBorder,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: CustomTextStyles.filterChipLabel,
        ),
      ),
    );
  }
}
