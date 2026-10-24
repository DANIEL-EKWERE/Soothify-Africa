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
              child: Obx(() {
                // Nobody has set any hours yet. The frame draws five rows
                // and no way to add one -- the chevron that opens the
                // picker lives inside a row -- so an expert who had set
                // none was looking at a blank screen with nothing to tap.
                if (controller.slots.isEmpty) return const _NoHoursYet();

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 16.v),
                  itemCount: controller.slots.length,
                  separatorBuilder: (_, _) => SizedBox(height: 24.v),
                  itemBuilder: (context, i) =>
                      _SlotRow(slot: controller.slots[i]),
                );
              }),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 25.v),
              // Each switch and each edited window reaches the server as it
              // is made -- an hour closed is an hour clients stop being
              // offered, and holding that until a Save would mean somebody
              // booking an hour the practitioner had already closed. So
              // this confirms and leaves.
              child: Obx(
                () => CustomElevatedButton(
                  // "Save Availability" in both frames.
                  //
                  // With no hours set it opens the picker instead: there
                  // is nothing to confirm, and a Save that only closes the
                  // screen is a button that lies about what it did.
                  text: controller.slots.isEmpty
                      ? 'Add your hours'
                      : 'Save Availability',
                  onPressed: () {
                    if (controller.slots.isEmpty) {
                      Get.toNamed(AppRoutes.expertSlotEditor);
                      return;
                    }
                    AppFeedback.info('Your hours are saved.');
                    Get.back();
                  },
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
          SizedBox(width: 10.h),
          // The frame puts a switch on every row — on for the slots a client
          // can book, off for the ones held back.
          Transform.scale(
            scale: 0.7,
            child: Switch.adaptive(
              value: slot.enabled,
              onChanged: (_) =>
                  Get.find<ExpertDashboardController>().toggleSlot(slot),
              activeThumbColor: appTheme.onPrimary,
              activeTrackColor: appTheme.soothifyBlue,
            ),
          ),
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


/// What the screen says before any hours have been set.
///
/// The frames draw five rows and assume they are there. Without this the
/// list was simply blank, and the only way into the picker was a chevron
/// on a row that did not exist.
class _NoHoursYet extends StatelessWidget {
  const _NoHoursYet();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, size: 32.h, color: appTheme.navInactive),
            SizedBox(height: 16.v),
            Text('No hours set yet',
                textAlign: TextAlign.center,
                style: CustomTextStyles.expertSlotDay),
            SizedBox(height: 8.v),
            Text(
              'Add the times you are free and clients can start booking '
              'them. You can close any of them again later.',
              textAlign: TextAlign.center,
              style: CustomTextStyles.expertBlurb,
            ),
          ],
        ),
      ),
    );
  }
}
