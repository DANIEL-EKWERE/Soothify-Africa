import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/expert_session.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../dashboard/controller/expert_dashboard_controller.dart';

/// "Update Availability" — Figma "Avaliability" (`259:59921`, and the time
/// picker at `259:60077`).
///
/// Measured: the title at 70, the blurb at 117, slot rows 342x76 from 178 at
/// a 100 pitch, and "Save Availability" at 688.
///
/// The frame misspells its own title as "Update Availabilty"; corrected.
class ExpertAvailabilityScreen extends GetView<ExpertDashboardController> {
  const ExpertAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 33.v),
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 24.h),
                    child: InkWell(
                      onTap: Get.back,
                      child: CustomImageView(
                        imagePath: ImageConstant.icBack,
                        height: 18.h,
                        width: 18.h,
                        color: appTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                Text('Update Availability',
                    style: CustomTextStyles.appBarTitle),
              ],
            ),
            SizedBox(height: 25.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: Text(
                'Clients can only book during the times you set below.',
                style: CustomTextStyles.expertBlurb,
              ),
            ),
            SizedBox(height: 37.v),
            Expanded(
              child: Obx(
                () => ListView.separated(
                  padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 16.v),
                  itemCount: controller.slots.length,
                  separatorBuilder: (_, _) => SizedBox(height: 24.v),
                  itemBuilder: (context, i) =>
                      _SlotRow(slot: controller.slots[i]),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 25.v),
              child: CustomElevatedButton(
                text: 'Save Availability',
                onPressed: () => AppFeedback.info(
                  'Saving availability is not built yet.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One bookable window: the weekday and its date on the left, the hours on
/// the right.
class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.slot});

  final AvailabilitySlot slot;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76.v,
      padding: EdgeInsets.symmetric(horizontal: 14.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(slot.weekday, style: CustomTextStyles.expertSlotDay),
                SizedBox(height: 8.v),
                Text(slot.date, style: CustomTextStyles.expertSlotDetail),
              ],
            ),
          ),
          Text(slot.range, style: CustomTextStyles.expertSlotDetail),
          SizedBox(width: 12.h),
          // The frame pairs each row with a wheel picker (`259:60077`),
          // drawn as its own full screen rather than a sheet.
          InkWell(
            onTap: () => Get.toNamed(
              AppRoutes.expertSlotEditor,
              arguments: slot,
            ),
            child: Icon(
              Icons.chevron_right,
              size: 20.h,
              color: appTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
