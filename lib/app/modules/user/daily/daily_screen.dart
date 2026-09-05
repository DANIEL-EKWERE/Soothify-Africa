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
        child: Obx(() => ListView(
              padding: EdgeInsets.fromLTRB(24.h, 17.v, 24.h, 32.v),
              children: [
                _Header(title: controller.title),
                SizedBox(height: 33.v),
                MonthCalendar(
                  month: controller.month.value,
                  selected: controller.selected.value,
                  onSelected: controller.selectDate,
                  compactWeekdays: true,
                ),
                SizedBox(height: 40.v),
                Text(
                  controller.emptyState,
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.emptyStateBody,
                ),
                SizedBox(height: 18.v),
                _Button(
                  label: 'Select date',
                  enabled: controller.selected.value != null,
                  onTap: () {},
                ),
                SizedBox(height: 13.v),
                _Button(
                  label: controller.startLabel,
                  enabled: true,
                  onTap: controller.openReminder,
                ),
              ],
            )),
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
  const _Button({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
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
          label,
          style: CustomTextStyles.subscribeLabel.copyWith(fontSize: 18.fSize),
        ),
      ),
    );
  }
}
