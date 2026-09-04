import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

/// The carousel's progress dots: 27x6 pills, 4 apart, fully rounded.
///
/// The design fills passed dots with the brand gradient, so the active ones
/// are painted with a shader rather than a flat colour.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(width: 4.h),
          Container(
            width: 27.h,
            height: 6.h,
            decoration: BoxDecoration(
              gradient: i <= index ? appTheme.titleGradient : null,
              color: i <= index ? null : appTheme.dotInactive,
              borderRadius: BorderRadius.circular(500),
            ),
          ),
        ],
      ],
    );
  }
}
