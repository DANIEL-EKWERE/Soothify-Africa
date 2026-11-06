import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../data/models/studio_partner.dart';
import '../../widgets/custom_elevated_button.dart';
import 'controller/partner_schedule_controller.dart';
import 'widgets/partner_chrome.dart';

/// The master schedule — Figma "5.1 · Master schedule & Sōōthify slots"
/// (`416:26376`).
///
/// Measured: the heading at 108, a 342x42 Day/Week/Month switcher at 179, a
/// 342x53 week picker at 229, the add button 342x48 at 290, three 108x90
/// KPIs at 358, the legend at 468, and the calendar from 516 — a 48 time
/// rail pinned beside a horizontally scrolling week of 156-wide columns,
/// one hour to every 64, from 6:00 AM to 9:00 PM.
class PartnerScheduleScreen extends GetView<PartnerScheduleController> {
  const PartnerScheduleScreen({super.key});

  /// The grid's own geometry, straight off the frame.
  static const double hourHeight = 64;
  static const double dayWidth = 156;
  static const int firstHour = 6;
  static const int lastHour = 21;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.passportPage,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.v),
            Row(
              children: [
                SizedBox(width: 24.h),
                InkWell(
                  onTap: Get.back,
                  customBorder: const CircleBorder(),
                  child: CustomImageView(
                    imagePath: ImageConstant.icChevronLeft,
                    height: 24.h,
                    width: 24.h,
                    color: appTheme.textPrimary,
                  ),
                ),
                Expanded(
                  child: Text('Master schedule & Soothify slots',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyles.partnerCardTitle
                          .copyWith(fontSize: 16.fSize)),
                ),
                SizedBox(width: 48.h),
              ],
            ),
            Expanded(
              child: Obx(
                () => ListView(
                  padding: EdgeInsets.fromLTRB(24.h, 20.v, 24.h, 32.v),
                  children: [
                    Text('Soothify slot manager',
                        style: CustomTextStyles.partnerSection
                            .copyWith(fontSize: 20.fSize)),
                    SizedBox(height: 8.v),
                    Text('Master schedule · Passport classes only',
                        style: CustomTextStyles.partnerMeta),
                    SizedBox(height: 20.v),
                    const _SpanSwitcher(),
                    SizedBox(height: 8.v),
                    const _WeekPicker(),
                    SizedBox(height: 8.v),
                    CustomElevatedButton(
                      text: 'Add Soothify Class Slot',
                      onPressed: controller.openAddSlot,
                    ),
                    SizedBox(height: 20.v),
                    _Kpis(schedule: controller.schedule.value),
                    SizedBox(height: 20.v),
                    const _Legend(),
                    SizedBox(height: 20.v),
                    _Calendar(controller: controller),
                    SizedBox(height: 20.v),
                    Text(
                      'Only classes with Passport allocations appear here. '
                      'Tap a class to manage its slots.',
                      style: CustomTextStyles.partnerMeta,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpanSwitcher extends StatelessWidget {
  const _SpanSwitcher();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PartnerScheduleController>();
    return Obx(
      () => Container(
        height: 42.v,
        padding: EdgeInsets.all(4.h),
        decoration: BoxDecoration(
          color: appTheme.partnerTabTrack,
          borderRadius: BorderRadius.circular(10.h),
        ),
        child: Row(
          children: [
            for (final (value, label) in const [
              (ScheduleSpan.day, 'Day'),
              (ScheduleSpan.week, 'Week'),
              (ScheduleSpan.month, 'Month'),
            ])
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.show(value),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: controller.span.value == value
                          ? appTheme.surface
                          : appTheme.transparent,
                      borderRadius: BorderRadius.circular(8.h),
                    ),
                    child: Text(
                      label,
                      style: CustomTextStyles.partnerTab.copyWith(
                        color: controller.span.value == value
                            ? appTheme.soothifyBlue
                            : appTheme.partnerMuted,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeekPicker extends StatelessWidget {
  const _WeekPicker();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PartnerScheduleController>();
    return Container(
      height: 53.v,
      padding: EdgeInsets.symmetric(horizontal: 12.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(10.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Row(
        children: [
          _Arrow(icon: Icons.chevron_left, onTap: controller.previousWeek),
          Expanded(
            child: Obx(
              () => Text(controller.weekLabel,
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.partnerCardBody),
            ),
          ),
          _Arrow(icon: Icons.chevron_right, onTap: controller.nextWeek),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: EdgeInsets.all(6.h),
        child: Icon(icon, size: 20.h, color: appTheme.partnerMuted),
      ),
    );
  }
}

class _Kpis extends StatelessWidget {
  const _Kpis({required this.schedule});

  final StudioSchedule? schedule;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Kpi(
            value: '${schedule?.slotsOpen ?? 0}',
            label: 'Soothify Slots Open',
          ),
        ),
        SizedBox(width: 8.h),
        Expanded(
          child: _Kpi(
            value: '${schedule?.passportBookings ?? 0}',
            label: 'Passport Bookings',
          ),
        ),
        SizedBox(width: 8.h),
        Expanded(
          child: _Kpi(
            value: '${schedule?.utilisation ?? 0}%',
            label: 'Slot Utilization Rate',
          ),
        ),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.v,
      padding: EdgeInsets.all(10.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: CustomTextStyles.partnerMetric),
          const Spacer(),
          Text(label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: CustomTextStyles.partnerMeta),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final category in StudioClassCategory.values) ...[
          Expanded(
            child: Container(
              height: 28.v,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: categoryWash(category),
                borderRadius: BorderRadius.circular(8.h),
              ),
              child: Text(category.label,
                  style: CustomTextStyles.partnerStatus
                      .copyWith(color: appTheme.textPrimary)),
            ),
          ),
          if (category != StudioClassCategory.values.last)
            SizedBox(width: 8.h),
        ],
      ],
    );
  }
}

/// The time rail pinned beside a week that scrolls sideways.
class _Calendar extends StatelessWidget {
  const _Calendar({required this.controller});

  final PartnerScheduleController controller;

  @override
  Widget build(BuildContext context) {
    final week = controller.schedule.value;
    final start = week?.weekStart ?? DateTime.now();
    final hours = PartnerScheduleScreen.lastHour -
        PartnerScheduleScreen.firstHour +
        1;
    final gridHeight = hours * PartnerScheduleScreen.hourHeight;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12.h, 14.v, 12.h, 10.v),
            child: Text(
              'WEEK ${week?.weekNumber ?? 0} · Swipe to view all 7 days',
              style: CustomTextStyles.partnerStatus
                  .copyWith(color: appTheme.partnerMuted),
            ),
          ),
          SizedBox(
            height: gridHeight.v + 32.v,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The rail stays put while the days move under it.
                SizedBox(
                  width: 48.h,
                  child: Column(
                    children: [
                      SizedBox(height: 32.v),
                      for (var h = PartnerScheduleScreen.firstHour;
                          h <= PartnerScheduleScreen.lastHour;
                          h++)
                        SizedBox(
                          height: PartnerScheduleScreen.hourHeight.v,
                          child: Padding(
                            padding: EdgeInsets.only(right: 6.h),
                            child: Text(
                              _hour(h),
                              textAlign: TextAlign.right,
                              style: CustomTextStyles.partnerStatus.copyWith(
                                fontSize: 10.fSize,
                                color: appTheme.partnerMuted,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: PartnerScheduleScreen.dayWidth.h * 7,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 32.v,
                            child: Row(
                              children: [
                                for (var d = 0; d < 7; d++)
                                  _DayHeading(
                                    day: start.add(Duration(days: d)),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: gridHeight.v,
                            child: Stack(
                              children: [
                                for (var h = 0; h <= hours; h++)
                                  Positioned(
                                    top: h *
                                        PartnerScheduleScreen.hourHeight.v,
                                    left: 0,
                                    right: 0,
                                    child: Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: appTheme.cardRim,
                                    ),
                                  ),
                                for (var d = 0; d < 7; d++)
                                  for (final slot in controller
                                      .on(start.add(Duration(days: d))))
                                    Positioned(
                                      left: d *
                                              PartnerScheduleScreen
                                                  .dayWidth.h +
                                          5.h,
                                      top: (slot.startsAt.hour -
                                                  PartnerScheduleScreen
                                                      .firstHour) *
                                              PartnerScheduleScreen
                                                  .hourHeight.v +
                                          4.v,
                                      child: _ClassBlock(slot: slot),
                                    ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _hour(int hour) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h:00\n${hour < 12 ? 'AM' : 'PM'}';
  }
}

class _DayHeading extends StatelessWidget {
  const _DayHeading({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Container(
      width: PartnerScheduleScreen.dayWidth.h,
      alignment: Alignment.center,
      color: appTheme.passportPage,
      child: Text('${names[day.weekday - 1]} ${day.day}',
          style: CustomTextStyles.partnerStatus
              .copyWith(color: appTheme.textPrimary)),
    );
  }
}

class _ClassBlock extends StatelessWidget {
  const _ClassBlock({required this.slot});

  final StudioClassSlot slot;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 146.h,
      height: 89.v,
      padding: EdgeInsets.all(8.h),
      decoration: BoxDecoration(
        color: categoryWash(slot.category),
        borderRadius: BorderRadius.circular(8.h),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(slot.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CustomTextStyles.partnerStatus
                  .copyWith(color: appTheme.textPrimary)),
          SizedBox(height: 2.v),
          Text(slot.when,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CustomTextStyles.partnerMeta.copyWith(fontSize: 10.fSize)),
          SizedBox(height: 2.v),
          Text('${slot.instructor} · ${slot.room}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CustomTextStyles.partnerMeta.copyWith(fontSize: 10.fSize)),
          const Spacer(),
          Text(
            slot.availability,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CustomTextStyles.partnerStatus.copyWith(
              fontSize: 10.fSize,
              // Full reads as a statement, open as something to act on.
              color: slot.isFull
                  ? appTheme.partnerMuted
                  : appTheme.soothifyBlue,
            ),
          ),
        ],
      ),
    );
  }
}
