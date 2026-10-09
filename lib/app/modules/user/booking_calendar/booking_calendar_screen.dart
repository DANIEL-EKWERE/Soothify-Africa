import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/month_calendar.dart';
import 'controller/booking_calendar_controller.dart';

/// "Schedule" — picking when the session runs.
///
/// Since the flow was reordered this comes straight after matching, before
/// payment: the time is chosen first and travels with the booking.
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
                  // The month sits on a card of its own, as the design draws
                  // it: white, rounded, lifted off the page's pale blue.
                  Container(
                    padding: EdgeInsets.fromLTRB(16.h, 16.v, 16.h, 18.v),
                    decoration: BoxDecoration(
                      color: appTheme.surface,
                      borderRadius: BorderRadius.circular(16.h),
                      border: Border.all(color: appTheme.cardRim),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                        SizedBox(height: 16.v),
                        Obx(
                          () => MonthCalendar(
                            month: controller.month.value,
                            selected: controller.selected.value,
                            onSelected: controller.pickDay,
                            // The stepper above already names the month; the
                            // grid was printing it a second time.
                            showMonthLabel: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28.v),
                  Text('Pick a time', style: CustomTextStyles.coachSection),
                  SizedBox(height: 12.v),
                  // Full-width rows, one per line, as the design draws them.
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final slot in BookingCalendarController.slots) ...[
                          _Slot(
                            label: slot,
                            chosen: controller.slot.value == slot,
                          ),
                          if (slot != BookingCalendarController.slots.last)
                            SizedBox(height: 10.v),
                        ],
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
        height: 44.v,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          // Choosing a time rings it in blue rather than filling it: the
          // filled treatment belongs to Confirm booking, and two solid blues
          // on one screen read as two actions.
          border: Border.all(
            color: chosen ? appTheme.soothifyBlue : appTheme.cardHairline,
            width: chosen ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: CustomTextStyles.coachChip.copyWith(
            color: chosen ? appTheme.soothifyBlue : appTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
