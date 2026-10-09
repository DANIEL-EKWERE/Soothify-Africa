import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/month_calendar.dart';
import 'controller/daily_controller.dart';

/// A daily habit's history — Figma "Profile/daily meditation" (135:8664) and
/// "Profile/daily balance" (135:8707).
///
/// One screen for both: the frames differ only in their title and button
/// label. The Balance frame reuses Meditation's empty-state wording, which is
/// a paste slip — the habit's own name is used instead.
class DailyScreen extends GetView<DailyController> {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(24.h, 17.v, 24.h, 32.v),
          children: [
            _Header(title: controller.title),
            SizedBox(height: 28.v),
            // A week, not a month: the redraw shows seven marks under a
            // month stepper, each one a day you either turned up for or
            // did not.
            const _WeekCard(),
            // Its own Obx, around the part that actually changes. Wrapping
            // the whole list meant one rebuild for everything and GetX
            // could not see what the rest of it was watching.
            Obx(
              () => controller.doneToday.value
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 90.v),
                        Text(
                          controller.emptyState,
                          textAlign: TextAlign.center,
                          style: CustomTextStyles.emptyStateBody,
                        ),
                        SizedBox(height: 20.v),
                        // Outlined: starting is an invitation, and the
                        // screen has nothing else on it to compete with.
                        _Button(
                          label: controller.startLabel,
                          onTap: controller.openStart,
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

/// The month stepper and its seven days, on a card of their own.
class _WeekCard extends StatelessWidget {
  const _WeekCard();

  static const _letters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DailyController>();
    return Container(
      padding: EdgeInsets.fromLTRB(16.h, 18.v, 16.h, 24.v),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Column(
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
                    MonthCalendar.label(controller.month.value),
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
          SizedBox(height: 20.v),
          // Not its own Obx: `moodFor` reads nothing observable yet, and an
          // Obx with no observable in it is what GetX reports as improper
          // use. The stepper above rebuilds the whole card when the month
          // changes, which is the only thing that moves these.
          Builder(
            builder: (context) => Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 30.h,
                          width: 30.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: appTheme.dayDotIdle,
                            shape: BoxShape.circle,
                          ),
                          child: controller.moodFor(i) == null
                              ? null
                              : CustomImageView(
                                  imagePath: controller.moodFor(i)!,
                                  height: 30.h,
                                  width: 30.h,
                                ),
                        ),
                        SizedBox(height: 10.v),
                        Text(_letters[i],
                            style: CustomTextStyles.calendarWeekday),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: Get.back,
          child: CustomImageView(
            imagePath: ImageConstant.icBack,
            height: 18.h,
            width: 18.h,
            color: appTheme.textPrimary,
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: CustomTextStyles.appBarTitle,
          ),
        ),
        SizedBox(width: 18.h),
      ],
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 52.v,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(color: appTheme.actionFill),
        ),
        child: Text(label, style: CustomTextStyles.dailyWhenLabel),
      ),
    );
  }
}
