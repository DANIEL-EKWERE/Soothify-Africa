import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// A month grid — Figma "Profile/history" (135:8133), "Profile/mood checkin"
/// (135:8253) and the booking calendar (135:21450).
///
/// Shared because those three frames draw the same control; keeping one widget
/// is what stops the weekday order or the selected-day treatment drifting
/// apart between them.
/// How a day is drawn.
enum MonthCalendarStyle {
  /// Just the number, filled behind only when it is the chosen day — the
  /// History calendar and the booking sheet.
  numbers,

  /// A filled circle with the number beneath it, and whatever [markBuilder]
  /// returns inside the circle — the mood check-in calendar.
  circles,
}

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.month,
    required this.selected,
    required this.onSelected,
    this.marked = const {},
    this.compactWeekdays = false,
    this.selectedColor,
    this.style = MonthCalendarStyle.numbers,
    this.markBuilder,
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

  final MonthCalendarStyle style;

  /// [MonthCalendarStyle.circles] only — what to draw inside a day's circle.
  /// Returning null leaves it empty, which is how a day with no entry reads.
  final Widget? Function(DateTime day)? markBuilder;

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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            // A circle cell stacks a 20 disc over its number, so it needs a
            // taller square than a bare number does.
            childAspectRatio:
                style == MonthCalendarStyle.circles ? 0.92 : 1.2,
          ),
          itemCount: leading + days,
          itemBuilder: (context, i) {
            if (i < leading) return const SizedBox.shrink();
            final day = i - leading + 1;
            final date = DateTime(month.year, month.month, day);
            final isSelected = selected != null &&
                DateUtils.isSameDay(selected, date);
            final isMarked = marked.any((d) => DateUtils.isSameDay(d, date));

            if (style == MonthCalendarStyle.circles) {
              return _CircleDay(
                day: day,
                date: date,
                selected: isSelected,
                selectedColor: selectedColor,
                mark: markBuilder?.call(date),
                onTap: () => onSelected(date),
              );
            }

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

/// A day in [MonthCalendarStyle.circles]: a filled disc with the number under
/// it, per Figma "Profile/mood checkin" (`176:34264`).
class _CircleDay extends StatelessWidget {
  const _CircleDay({
    required this.day,
    required this.date,
    required this.selected,
    required this.selectedColor,
    required this.mark,
    required this.onTap,
  });

  final int day;
  final DateTime date;
  final bool selected;
  final Color? selectedColor;
  final Widget? mark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 20.h,
            width: 20.h,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: selected
                  ? (selectedColor ?? appTheme.actionFill)
                  : appTheme.dayEmpty,
              shape: BoxShape.circle,
            ),
            child: mark,
          ),
          SizedBox(height: 5.v),
          Text('$day', style: CustomTextStyles.calendarDay),
        ],
      ),
    );
  }
}
