import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/utils/media_entry.dart';
import '../../../../data/models/profile_stats.dart';
import '../../../../widgets/month_calendar.dart';
import '../controller/profile_tab_controller.dart';

/// The History tab — Figma "Profile/history" (page 124:2, `176:34144`).
///
/// The month grid sits inside a white card with a hairline, and the chosen day
/// is filled orange rather than the blue the app's other calendars use.
/// The list under the calendar is what was actually played, newest first --
/// the same rows the dashboard's "Recent activity" is built from. The empty
/// state shows only when there is genuinely nothing.
///
/// The frame has no "Select date" button — the earlier build added one, and a
/// disabled button under an empty calendar read as a dead end.
///
/// Note on the frame's own calendar: it prints 1 August 2024 under Monday,
/// but that was a Thursday. The grid here is correct; do not "fix" it to match
/// the render.
class ProfileHistory extends StatelessWidget {
  const ProfileHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileTabController>();
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('My Calendar', style: CustomTextStyles.statsHeading),
            SizedBox(height: 19.v),
            Container(
              padding: EdgeInsets.fromLTRB(22.h, 24.v, 22.h, 24.v),
              decoration: BoxDecoration(
                color: appTheme.surface,
                borderRadius: BorderRadius.circular(12.h),
                border: Border.all(color: appTheme.calendarCardBorder),
              ),
              child: MonthCalendar(
                month: controller.month.value,
                selected: controller.selectedDate.value,
                // Dotted where something was done, so the month says at a
                // glance which days are worth tapping.
                marked: controller.daysWithActivity,
                onSelected: controller.selectDate,
                selectedColor: appTheme.daySelected,
              ),
            ),
            SizedBox(height: 28.v),
            if (controller.historyForSelectedDay.isEmpty)
              Text(
                controller.stats.value.recent.isEmpty
                    ? 'Your history will show here after your first\nsession.'
                    : controller.showingToday
                        ? 'Nothing done yet today.'
                        : 'Nothing on this day.',
                textAlign: TextAlign.center,
                style: CustomTextStyles.emptyStateBody,
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: appTheme.surface,
                  borderRadius: BorderRadius.circular(12.h),
                  border: Border.all(color: appTheme.calendarCardBorder),
                ),
                child: Column(
                  children: [
                    for (final row in controller.historyForSelectedDay) ...[
                      _HistoryRow(row: row),
                      if (row != controller.historyForSelectedDay.last)
                        Divider(height: 1, color: appTheme.cardRim),
                    ],
                  ],
                ),
              ),
          ],
        ));
  }
}

/// One line of history: when, then what — the order the frame prints them,
/// which reads as a log rather than as a card.
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.row});

  final RecentPlay row;

  @override
  Widget build(BuildContext context) {
    final length = row.lengthLabel;
    return InkWell(
      onTap: () => openMedia(row.item, source: 'History'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 14.v),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.h),
              child: CustomImageView(
                imagePath: row.item.cover,
                height: 48.h,
                width: 48.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 14.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.agoFor(DateTime.now()),
                    style: CustomTextStyles.emptyStateBody,
                  ),
                  SizedBox(height: 4.v),
                  Text(
                    length.isEmpty
                        ? row.item.title
                        : '${row.item.title} - $length',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles.statsHeading
                        .copyWith(fontSize: 15.fSize),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
