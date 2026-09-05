import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/month_calendar.dart';
import '../controller/booking_controller.dart';

/// The "Schedule for later" date picker — Figma "Matched with instructor/
/// calendar sc" (135:21450).
///
/// A sheet rather than a screen: the calendar frame is the coach profile with
/// this laid over its lower half, the profile still visible behind.
class ScheduleSheet extends StatelessWidget {
  const ScheduleSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        backgroundColor: appTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.h)),
        ),
        builder: (_) => const ScheduleSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();
    return Obx(() {
      return Padding(
        padding: EdgeInsets.fromLTRB(24.h, 20.v, 24.h, 24.v),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select dates', style: CustomTextStyles.coachSection),
            SizedBox(height: 24.v),
            MonthCalendar(
              month: controller.calendarMonth.value,
              selected: controller.scheduledFor.value,
              onSelected: (d) => controller.scheduledFor.value = d,
            ),
            SizedBox(height: 16.v),
            InkWell(
              onTap: () {
                final picked = controller.scheduledFor.value;
                if (picked == null) return;
                Navigator.of(context).pop();
                controller.schedule(picked);
              },
              borderRadius: BorderRadius.circular(8.h),
              child: Container(
                height: 52.v,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  // Disabled until a day is chosen, as with the other
                  // primary buttons in this flow.
                  color: controller.scheduledFor.value == null
                      ? appTheme.actionFillDisabled
                      : appTheme.actionFill,
                  borderRadius: BorderRadius.circular(8.h),
                ),
                child: Text(
                  'Select date',
                  style: CustomTextStyles.subscribeLabel
                      .copyWith(fontSize: 18.fSize),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

}
