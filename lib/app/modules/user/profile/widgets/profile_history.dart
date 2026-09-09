import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/month_calendar.dart';
import '../controller/profile_tab_controller.dart';

/// The History tab — Figma "Profile/history" (page 124:2, `176:34144`).
///
/// The month grid sits inside a white card with a hairline, and the chosen day
/// is filled orange rather than the blue the app's other calendars use.
/// Nothing records sessions yet, so the empty state below is the honest view
/// rather than a seeded history.
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
                onSelected: controller.selectDate,
                selectedColor: appTheme.daySelected,
              ),
            ),
            SizedBox(height: 28.v),
            Text(
              'Your history will show here after your first\nsession.',
              textAlign: TextAlign.center,
              style: CustomTextStyles.emptyStateBody,
            ),
          ],
        ));
  }
}
