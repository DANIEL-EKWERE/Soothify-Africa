import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

/// The week's check-in streak: a tick for each day already logged, an empty
/// ring for days still ahead, and today drawn larger.
///
/// Measured from Figma `135:2056` — columns 44 wide and 48 apart, marks 24
/// square except today's 44, ticks in brand blue, empty rings outlined
/// `#999B9E`.
class StreakStrip extends StatelessWidget {
  const StreakStrip({
    super.key,
    required this.labels,
    required this.completed,
    required this.todayIndex,
  });

  /// Seven short weekday names, starting Sunday.
  final List<String> labels;

  /// Which of those days have a check-in.
  final List<bool> completed;

  /// -1 when the week on screen is not the current one.
  final int todayIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < labels.length; i++)
          _Day(
            label: labels[i],
            isDone: completed[i],
            isToday: i == todayIndex,
          ),
      ],
    );
  }
}

class _Day extends StatelessWidget {
  const _Day({
    required this.label,
    required this.isDone,
    required this.isToday,
  });

  final String label;
  final bool isDone;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final size = isToday ? 44.h : 24.h;

    return SizedBox(
      width: 44.h,
      child: Column(
        // The enclosing Row sits in a Column, so it is handed an unbounded
        // height; without this the day column tries to fill infinity.
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: isToday
                ? CustomTextStyles.streakDayToday
                : CustomTextStyles.weekdayLabel,
          ),
          // Today's larger mark keeps its centre on the same line as the
          // others, so the row does not look ragged.
          SizedBox(height: isToday ? 6.h : 16.h),
          SizedBox(
            width: size,
            height: size,
            child: isDone
                ? CustomImageView(
                    imagePath: ImageConstant.icTickCircle,
                    height: size,
                    width: size,
                    color: appTheme.soothifyBlue,
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: appTheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: appTheme.streakRing),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
