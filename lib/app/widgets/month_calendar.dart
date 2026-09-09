import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// A month grid — Figma "Profile/history" (135:8133), "Profile/mood checkin"
/// (135:8253) and the booking calendar (135:21450).
///
/// Shared because those three frames draw the same control; keeping one widget
/// is what stops the weekday order or the selected-day treatment drifting
/// apart between them.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.month,
    required this.selected,
    required this.onSelected,
    this.marked = const {},
    this.compactWeekdays = false,
    this.selectedColor,
  });

  final DateTime month;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;

  /// Days with something recorded against them — dotted in the design's
  /// check-in calendars.
  final Set<DateTime> marked;

  /// The daily-habit frames label the columns with single letters rather than
  /// "Mon".."Sun".
  final bool compactWeekdays;

  /// Fill behind the chosen day. Defaults to the brand blue every calendar
  /// but Profile/History uses; that frame selects in orange.
  final Color? selectedColor;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static String label(DateTime m) => '${_months[m.month - 1]} ${m.year}';

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    // Monday-first, matching the design's Mon..Sun header.
    final leading = (first.weekday + 6) % 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label(month), style: CustomTextStyles.calendarMonth),
        SizedBox(height: 16.v),
        Row(
          children: [
            for (final d in _weekdays)
              Expanded(
                child: Text(
                  compactWeekdays ? d[0] : d,
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.calendarWeekday,
                ),
              ),
          ],
        ),
        SizedBox(height: 8.v),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.2,
          ),
          itemCount: leading + days,
          itemBuilder: (context, i) {
            if (i < leading) return const SizedBox.shrink();
            final day = i - leading + 1;
            final date = DateTime(month.year, month.month, day);
            final isSelected = selected != null &&
                DateUtils.isSameDay(selected, date);
            final isMarked = marked.any((d) => DateUtils.isSameDay(d, date));

            return InkWell(
              onTap: () => onSelected(date),
              customBorder: const CircleBorder(),
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(2.h),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? (selectedColor ?? appTheme.actionFill)
                          : appTheme.transparent,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: CustomTextStyles.calendarDay.copyWith(
                        color: isSelected
                            ? appTheme.onPrimary
                            : appTheme.textPrimary,
                      ),
                    ),
                    if (isMarked && !isSelected)
                      Container(
                        width: 4.h,
                        height: 4.h,
                        margin: EdgeInsets.only(top: 2.v),
                        decoration: BoxDecoration(
                          color: appTheme.soothifyBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
