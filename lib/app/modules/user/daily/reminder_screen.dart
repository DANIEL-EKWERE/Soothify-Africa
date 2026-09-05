import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import 'controller/daily_controller.dart';

/// Setting a habit reminder — Figma "Profile/reminder/meditation" (135:8888)
/// and "Profirle/reminder" (135:9181).
///
/// The frames at 135:8929 and 135:8999 are this screen with the platform time
/// picker open on its hour and minute faces, so the picker itself is the
/// system one rather than a hand-built clock.
class ReminderScreen extends GetView<DailyController> {
  const ReminderScreen({super.key});

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.h, 17.v, 24.h, 32.v),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
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
                      controller.reminderTitle,
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.appBarTitle,
                    ),
                  ),
                  SizedBox(width: 18.h),
                ],
              ),
              SizedBox(height: 30.v),
              Text(controller.reminderBlurb,
                  style: CustomTextStyles.emptyStateBody),
              SizedBox(height: 39.v),
              Text(
                'When would you like to check-in?',
                style: CustomTextStyles.coachSection,
              ),
              SizedBox(height: 20.v),
              Obx(() => _TimeField(
                    time: controller.reminderAt.value,
                    onTap: () => _pickTime(context),
                  )),
              SizedBox(height: 46.v),
              Text(
                'Choose which days you’d like a reminder',
                style: CustomTextStyles.coachSection,
              ),
              SizedBox(height: 16.v),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < 7; i++)
                        _DayToggle(
                          label: _labels[i],
                          // DateTime.monday is 1.
                          selected: controller.reminderDays.contains(i + 1),
                          onTap: () => controller.toggleDay(i + 1),
                        ),
                    ],
                  )),
              const Spacer(),
              Obx(() => _SetButton(
                    enabled: controller.canSetReminder,
                    onTap: controller.setReminder,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: controller.reminderAt.value,
    );
    if (picked != null) controller.setTime(picked);
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.time, required this.onTap});

  final TimeOfDay time;
  final VoidCallback onTap;

  String get _label {
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 56.v,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(color: appTheme.optionBorder),
        ),
        child: Text(_label, style: CustomTextStyles.callName),
      ),
    );
  }
}

class _DayToggle extends StatelessWidget {
  const _DayToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40.h,
        height: 40.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? appTheme.actionFill : appTheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: appTheme.segmentBorder),
        ),
        child: Text(
          label,
          style: CustomTextStyles.calendarDay.copyWith(
            color: selected ? appTheme.onPrimary : appTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SetButton extends StatelessWidget {
  const _SetButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 52.v,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? appTheme.actionFill : appTheme.actionFillDisabled,
          borderRadius: BorderRadius.circular(8.h),
        ),
        child: Text(
          'Set Reminder',
          style: CustomTextStyles.subscribeLabel.copyWith(fontSize: 18.fSize),
        ),
      ),
    );
  }
}
