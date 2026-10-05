import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/month_calendar.dart';
import 'controller/booking_calendar_controller.dart';

/// "Book your session" — the calendar the receipt leads to.
///
/// The step the flow was missing: after paying, this is where the session is
/// actually placed in the week.
class BookingCalendarScreen extends GetView<BookingCalendarController> {
  const BookingCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 17.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: Get.back,
                    child: CustomImageView(
                      imagePath: ImageConstant.icBack,
                      height: 24.h,
                      width: 24.h,
                      color: appTheme.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Schedule',
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.appBarTitle,
                    ),
                  ),
                  SizedBox(width: 24.h),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 34.v, 24.h, 24.v),
                children: [
                  Text(
                    'Pick a day for your session',
                    style: CustomTextStyles.coachSection,
                  ),
                  SizedBox(height: 20.v),
                  Obx(
                    () => Row(
                      children: [
                        InkWell(
                          onTap: controller.previousMonth,
                          customBorder: const CircleBorder(),
                          child: Icon(Icons.chevron_left,
                              size: 22.h, color: appTheme.textPrimary),
                        ),
                        Expanded(
                          child: Text(
                            controller.monthLabel,
                            textAlign: TextAlign.center,
                            style: CustomTextStyles.coachHeading,
                          ),
                        ),
                        InkWell(
                          onTap: controller.nextMonth,
                          customBorder: const CircleBorder(),
                          child: Icon(Icons.chevron_right,
                              size: 22.h, color: appTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.v),
                  Obx(
                    () => MonthCalendar(
                      month: controller.month.value,
                      selected: controller.selected.value,
                      onSelected: controller.pickDay,
                    ),
                  ),
                  SizedBox(height: 28.v),
                  Text('Pick a time', style: CustomTextStyles.coachSection),
                  SizedBox(height: 12.v),
                  Obx(
                    () => Wrap(
                      spacing: 10.h,
                      runSpacing: 10.v,
                      children: [
                        for (final slot in BookingCalendarController.slots)
                          _Slot(
                            label: slot,
                            chosen: controller.slot.value == slot,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 32.v),
              child: Obx(
                () => CustomElevatedButton(
                  text: 'Confirm booking',
                  isEnabled: controller.canConfirm,
                  onPressed: controller.canConfirm ? controller.confirm : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({required this.label, required this.chosen});

  final String label;
  final bool chosen;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingCalendarController>();
    return InkWell(
      onTap: () => controller.pickSlot(label),
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 40.v,
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: chosen ? appTheme.actionFill : appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(
            color: chosen ? appTheme.actionFill : appTheme.cardHairline,
          ),
        ),
        child: Text(
          label,
          style: CustomTextStyles.coachChip.copyWith(
            color: chosen ? appTheme.onPrimary : appTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
