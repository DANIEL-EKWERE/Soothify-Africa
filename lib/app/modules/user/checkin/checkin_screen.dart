import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/month_calendar.dart';
import 'controller/checkin_controller.dart';

/// A check-in history — Figma "Profile/mood checkin" (135:8253, 135:8481).
///
/// Months stacked newest first, and the chosen day's entry beneath. The design
/// splits these across two frames; they are one screen because the entry only
/// exists once a day is picked.
class CheckinScreen extends GetView<CheckinController> {
  const CheckinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 17.v, 24.h, 0),
              child: Row(
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
                      controller.kind.title,
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.appBarTitle,
                    ),
                  ),
                  SizedBox(width: 18.h),
                ],
              ),
            ),
            Expanded(
              child: Obx(() => ListView(
                    padding: EdgeInsets.fromLTRB(24.h, 30.v, 24.h, 32.v),
                    children: [
                      if (controller.entry.value != null) ...[
                        _EntryCard(
                          when: controller.entry.value!.recordedAt,
                          label: controller.entry.value!.level.label,
                        ),
                        SizedBox(height: 32.v),
                      ],
                      for (final month in controller.months) ...[
                        MonthCalendar(
                          month: month,
                          selected: controller.selected.value,
                          marked: controller.marked,
                          onSelected: controller.selectDate,
                        ),
                        SizedBox(height: 24.v),
                        _SelectButton(
                          enabled: controller.selected.value != null,
                          onTap: controller.confirm,
                        ),
                        SizedBox(height: 18.v),
                      ],
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.when, required this.label});

  final DateTime when;
  final String label;

  static const _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
    'Sunday',
  ];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// "Thursday, 4 Jul, 12:01 pm", as the frame prints it.
  String get _stamp {
    final h24 = when.hour;
    final h = h24 % 12 == 0 ? 12 : h24 % 12;
    final m = when.minute.toString().padLeft(2, '0');
    final ampm = h24 < 12 ? 'am' : 'pm';
    return '${_days[when.weekday - 1]}, ${when.day} '
        '${_months[when.month - 1]}, $h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_stamp, style: CustomTextStyles.emptyStateBody),
        SizedBox(height: 21.v),
        Text(label, style: CustomTextStyles.statsHeading),
      ],
    );
  }
}

class _SelectButton extends StatelessWidget {
  const _SelectButton({required this.enabled, required this.onTap});

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
          'Select date',
          style: CustomTextStyles.subscribeLabel.copyWith(fontSize: 18.fSize),
        ),
      ),
    );
  }
}
