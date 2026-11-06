import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';
import '../../data/models/studio_partner.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_ghost_button.dart';
import 'controller/add_slot_controller.dart';

/// "Add Sōōthify Class Slot" — Figma `416:26557`.
///
/// A sheet, as the frame draws it: a drag handle, the title with its × at
/// the right, then the form — class details, schedule, the Passport spot
/// allocation on its own pale panel, the off-peak switch, and recurrence —
/// ending on Create and Cancel.
class AddSlotScreen extends GetView<AddSlotController> {
  const AddSlotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 13.v),
            Container(
              width: 40.h,
              height: 4.v,
              decoration: BoxDecoration(
                color: appTheme.sheetHandle,
                borderRadius: BorderRadius.circular(2.h),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 20.v, 24.h, 24.v),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Add Soothify Class Slot',
                            style: CustomTextStyles.partnerSection
                                .copyWith(fontSize: 20.fSize)),
                      ),
                      InkWell(
                        onTap: Get.back,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: EdgeInsets.all(4.h),
                          child: Icon(Icons.close,
                              size: 22.h, color: appTheme.partnerMuted),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.v),
                  Text(
                    'Select a class on your schedule and choose how many '
                    'spots to reserve for Soothify Passport members.',
                    style: CustomTextStyles.partnerMeta
                        .copyWith(fontSize: 14.fSize),
                  ),
                  SizedBox(height: 24.v),
                  Text('Class details',
                      style: CustomTextStyles.partnerSection),
                  SizedBox(height: 12.v),
                  const _CategoryField(),
                  SizedBox(height: 6.v),
                  Text('Available: Reformer · Mat · Yoga',
                      style: CustomTextStyles.partnerMeta
                          .copyWith(fontSize: 11.fSize)),
                  SizedBox(height: 14.v),
                  _Field(
                    label: 'Class Title',
                    controller: controller.title,
                    hint: 'Reformer Flow',
                    onChanged: (_) => controller.touch(),
                  ),
                  SizedBox(height: 14.v),
                  _Field(
                    label: 'Instructor Name',
                    controller: controller.instructor,
                    hint: 'Kemi A.',
                    onChanged: (_) => controller.touch(),
                  ),
                  SizedBox(height: 14.v),
                  _Field(
                    label: 'Room / Studio',
                    controller: controller.room,
                    hint: 'Studio A',
                    onChanged: (_) => controller.touch(),
                  ),
                  SizedBox(height: 24.v),
                  Text('Schedule', style: CustomTextStyles.partnerSection),
                  SizedBox(height: 12.v),
                  const _DateField(),
                  SizedBox(height: 14.v),
                  const _TimeAndDuration(),
                  SizedBox(height: 24.v),
                  const _Allocation(),
                  SizedBox(height: 20.v),
                  const _OffPeak(),
                  SizedBox(height: 24.v),
                  Text('Recurrence automation',
                      style: CustomTextStyles.partnerSection),
                  SizedBox(height: 12.v),
                  const _Recurrence(),
                  SizedBox(height: 24.v),
                  Obx(
                    () => CustomElevatedButton(
                      text: 'Create Soothify Class Slot',
                      isEnabled: controller.canCreate,
                      isLoading: controller.saving.value,
                      onPressed: controller.create,
                    ),
                  ),
                  SizedBox(height: 8.v),
                  CustomGhostButton(text: 'Cancel', onPressed: Get.back),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A labelled box, the shape every field on this sheet takes.
class _Boxed extends StatelessWidget {
  const _Boxed({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: CustomTextStyles.partnerMeta),
        SizedBox(height: 6.v),
        Container(
          height: 44.v,
          padding: EdgeInsets.symmetric(horizontal: 14.h),
          decoration: BoxDecoration(
            color: appTheme.surface,
            borderRadius: BorderRadius.circular(10.h),
            border: Border.all(color: appTheme.fieldRim),
          ),
          child: Center(child: child),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _Boxed(
      label: label,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: CustomTextStyles.partnerCardBody,
        cursorColor: appTheme.soothifyBlue,
        decoration: InputDecoration(
          isDense: true,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: hint,
          hintStyle: CustomTextStyles.partnerMeta,
        ),
      ),
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddSlotController>();
    return Obx(
      () => _Boxed(
        label: 'Category',
        child: Row(
          children: [
            Expanded(
              child: Text(controller.category.value.label,
                  style: CustomTextStyles.partnerCardBody),
            ),
            PopupMenuButton<StudioClassCategory>(
              onSelected: controller.choose,
              itemBuilder: (context) => [
                for (final c in StudioClassCategory.values)
                  PopupMenuItem(value: c, child: Text(c.label)),
              ],
              child: Icon(Icons.keyboard_arrow_down,
                  size: 20.h, color: appTheme.partnerMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddSlotController>();
    return Obx(
      () => GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: controller.day.value,
            firstDate: DateTime.now().subtract(const Duration(days: 1)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) controller.day.value = picked;
        },
        child: _Boxed(
          label: 'Date',
          child: Row(
            children: [
              Expanded(
                child: Text(
                    DateFormat('dd MMM yyyy').format(controller.day.value),
                    style: CustomTextStyles.partnerCardBody),
              ),
              Icon(Icons.calendar_today_outlined,
                  size: 16.h, color: appTheme.partnerMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeAndDuration extends StatelessWidget {
  const _TimeAndDuration();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddSlotController>();
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: controller.startMinute.value ~/ 60,
                    minute: controller.startMinute.value % 60,
                  ),
                );
                if (picked != null) {
                  controller.startMinute.value =
                      picked.hour * 60 + picked.minute;
                }
              },
              child: _Boxed(
                label: 'Start Time',
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(controller.startLabel,
                      style: CustomTextStyles.partnerCardBody),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.h),
          Expanded(
            child: _Boxed(
              label: 'Session Duration',
              child: Row(
                children: [
                  Expanded(
                    child: Text(controller.durationLabel,
                        style: CustomTextStyles.partnerCardBody),
                  ),
                  PopupMenuButton<int>(
                    onSelected: (value) => controller.duration.value = value,
                    itemBuilder: (context) => [
                      for (final m in const [30, 45, 60, 75, 90])
                        PopupMenuItem(value: m, child: Text('$m minutes')),
                    ],
                    child: Icon(Icons.keyboard_arrow_down,
                        size: 20.h, color: appTheme.partnerMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The pale panel: how many places Soothify members may take.
class _Allocation extends StatelessWidget {
  const _Allocation();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddSlotController>();
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: appTheme.partnerAllocation,
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Soothify Passport Spot Allocation',
              style: CustomTextStyles.partnerCardTitle),
          SizedBox(height: 8.v),
          Text(
            'Reserve an exact number of spots for Passport members.',
            style: CustomTextStyles.partnerMeta,
          ),
          SizedBox(height: 12.v),
          Obx(
            () => Container(
              height: 47.v,
              padding: EdgeInsets.symmetric(horizontal: 8.h),
              decoration: BoxDecoration(
                color: appTheme.surface,
                borderRadius: BorderRadius.circular(10.h),
                border: Border.all(color: appTheme.cardRim),
              ),
              child: Row(
                children: [
                  _Step(icon: Icons.remove, onTap: controller.fewer),
                  Expanded(
                    child: Text(
                      '${controller.spots.value} '
                      '${controller.spots.value == 1 ? 'spot' : 'spots'}',
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.partnerCardBody,
                    ),
                  ),
                  _Step(icon: Icons.add, onTap: controller.more),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.v),
          Obx(() => Text(controller.allocation,
              style: CustomTextStyles.partnerMeta
                  .copyWith(fontSize: 11.fSize))),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 32.h,
        height: 32.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: appTheme.partnerTabTrack,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18.h, color: appTheme.soothifyBlue),
      ),
    );
  }
}

class _OffPeak extends StatelessWidget {
  const _OffPeak();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddSlotController>();
    return Obx(
      () => GestureDetector(
        onTap: () => controller.offPeak.value = !controller.offPeak.value,
        behavior: HitTestBehavior.opaque,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22.h,
              height: 22.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: controller.offPeak.value
                    ? appTheme.soothifyBlue
                    : appTheme.surface,
                borderRadius: BorderRadius.circular(6.h),
                border: Border.all(
                  color: controller.offPeak.value
                      ? appTheme.soothifyBlue
                      : appTheme.fieldRim,
                ),
              ),
              child: controller.offPeak.value
                  ? Icon(Icons.check, size: 14.h, color: appTheme.onPrimary)
                  : null,
            ),
            SizedBox(width: 10.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mark as Off-Peak Session',
                      style: CustomTextStyles.partnerCardBody),
                  SizedBox(height: 2.v),
                  Text('Gives higher visibility in Soothify app feed.',
                      style: CustomTextStyles.partnerMeta),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Recurrence extends StatelessWidget {
  const _Recurrence();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddSlotController>();
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final option in SlotRecurrence.values) ...[
            GestureDetector(
              onTap: () => controller.repeat(option),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 48.v,
                padding: EdgeInsets.symmetric(horizontal: 14.h),
                decoration: BoxDecoration(
                  color: controller.recurrence.value == option
                      ? appTheme.partnerQueuedFill
                      : appTheme.surface,
                  borderRadius: BorderRadius.circular(10.h),
                  border: Border.all(color: appTheme.cardRim),
                ),
                child: Row(
                  children: [
                    Icon(
                      controller.recurrence.value == option
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 18.h,
                      color: controller.recurrence.value == option
                          ? appTheme.soothifyBlue
                          : appTheme.partnerMuted,
                    ),
                    SizedBox(width: 10.h),
                    Text(option.label,
                        style: CustomTextStyles.partnerCardBody),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.v),
          ],
          if (controller.recurrence.value == SlotRecurrence.custom) ...[
            Row(
              children: [
                for (var weekday = 1; weekday <= 7; weekday++) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.toggleDay(weekday),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 38.v,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: controller.days.contains(weekday)
                              ? appTheme.soothifyBlue
                              : appTheme.surface,
                          borderRadius: BorderRadius.circular(8.h),
                          border: Border.all(color: appTheme.cardRim),
                        ),
                        child: Text(
                          const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][weekday - 1],
                          style: CustomTextStyles.partnerStatus.copyWith(
                            color: controller.days.contains(weekday)
                                ? appTheme.onPrimary
                                : appTheme.partnerMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (weekday < 7) SizedBox(width: 6.h),
                ],
              ],
            ),
            SizedBox(height: 12.v),
          ],
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: controller.expires.value,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 730)),
              );
              if (picked != null) controller.expires.value = picked;
            },
            child: _Boxed(
              label: 'Expiration Date',
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                        DateFormat('dd MMM yyyy')
                            .format(controller.expires.value),
                        style: CustomTextStyles.partnerCardBody),
                  ),
                  Icon(Icons.calendar_today_outlined,
                      size: 16.h, color: appTheme.partnerMuted),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.v),
          Text(controller.recurrenceSummary,
              style: CustomTextStyles.partnerMeta
                  .copyWith(fontSize: 11.fSize)),
        ],
      ),
    );
  }
}
