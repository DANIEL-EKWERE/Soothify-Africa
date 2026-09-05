import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/month_calendar.dart';
import '../controller/profile_tab_controller.dart';

/// The History tab — Figma "Profile/history" (135:8133).
///
/// A month calendar over an empty state. Nothing records sessions yet, so the
/// empty state is the honest view rather than a seeded history.
class ProfileHistory extends StatelessWidget {
  const ProfileHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileTabController>();
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('My Calendar', style: CustomTextStyles.statsHeading),
            SizedBox(height: 32.v),
            MonthCalendar(
              month: controller.month.value,
              selected: controller.selectedDate.value,
              onSelected: controller.selectDate,
            ),
            SizedBox(height: 44.v),
            Text(
              'Your history will show here after your first\nsession.',
              textAlign: TextAlign.center,
              style: CustomTextStyles.emptyStateBody,
            ),
            SizedBox(height: 24.v),
            _SelectDateButton(
              enabled: controller.selectedDate.value != null,
              onTap: controller.confirmDate,
            ),
          ],
        ));
  }
}

class _SelectDateButton extends StatelessWidget {
  const _SelectDateButton({required this.enabled, required this.onTap});

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
