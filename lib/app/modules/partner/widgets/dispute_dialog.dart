import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/studio_partner.dart';
import '../controller/roster_controller.dart';

/// "Dispute check-in" — Figma `416:26781`.
///
/// A dialog over the roster rather than a route: the desk is mid-queue with
/// a member standing in front of them, and the thing behind it has to stay
/// where it was.
Future<void> showDisputeDialog(BuildContext context) => Get.dialog<void>(
      const _DisputeDialog(),
      barrierColor: Colors.black.withValues(alpha: 0.55),
    );

class _DisputeDialog extends StatelessWidget {
  const _DisputeDialog();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RosterController>();
    final member = controller.failure.value?.member;
    return Dialog(
      backgroundColor: appTheme.surface,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Dispute check-in',
                      style: CustomTextStyles.partnerSection
                          .copyWith(fontSize: 18.fSize)),
                ),
                InkWell(
                  onTap: Get.back,
                  customBorder: const CircleBorder(),
                  child: Icon(Icons.close,
                      size: 20.h, color: appTheme.partnerMuted),
                ),
              ],
            ),
            SizedBox(height: 12.v),
            if (member != null)
              Text('${member.name} · Reformer Flow',
                  style: CustomTextStyles.partnerCardBody),
            SizedBox(height: 10.v),
            Text(
              'Select all reasons that apply. The member can enter class '
              'while this is reviewed.',
              style: CustomTextStyles.partnerMeta,
            ),
            SizedBox(height: 16.v),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final problem in CheckInProblem.values) ...[
                    GestureDetector(
                      onTap: () => controller.toggleReason(problem),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 46.v,
                        padding: EdgeInsets.symmetric(horizontal: 12.h),
                        decoration: BoxDecoration(
                          color: controller.reasons.contains(problem)
                              ? appTheme.partnerQueuedFill
                              : appTheme.surface,
                          borderRadius: BorderRadius.circular(10.h),
                          border: Border.all(color: appTheme.cardRim),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              controller.reasons.contains(problem)
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 18.h,
                              color: controller.reasons.contains(problem)
                                  ? appTheme.soothifyBlue
                                  : appTheme.partnerMuted,
                            ),
                            SizedBox(width: 10.h),
                            Text(problem.label,
                                style: CustomTextStyles.partnerCardBody),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8.v),
                  ],
                ],
              ),
            ),
            SizedBox(height: 8.v),
            Container(
              padding: EdgeInsets.all(14.h),
              decoration: BoxDecoration(
                color: appTheme.partnerOfflineFill,
                borderRadius: BorderRadius.circular(10.h),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Entry now, review later',
                      style: CustomTextStyles.partnerCardTitle
                          .copyWith(color: appTheme.partnerOfflineInk)),
                  SizedBox(height: 4.v),
                  Text(
                    'Status becomes Provisionally Verified. A report is '
                    'sent to the admin log.',
                    style: CustomTextStyles.partnerMeta
                        .copyWith(color: appTheme.partnerOfflineInk),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.v),
            Obx(
              () => InkWell(
                onTap: controller.canSubmitDispute
                    ? controller.grantEntry
                    : null,
                borderRadius: BorderRadius.circular(10.h),
                child: Container(
                  height: 48.v,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: controller.canSubmitDispute
                        ? appTheme.passportAction
                        : appTheme.partnerTabTrack,
                    borderRadius: BorderRadius.circular(10.h),
                  ),
                  child: Text('Submit & Grant Entry',
                      style: CustomTextStyles.partnerCardTitle.copyWith(
                        color: controller.canSubmitDispute
                            ? appTheme.onPrimary
                            : appTheme.partnerMuted,
                      )),
                ),
              ),
            ),
            SizedBox(height: 12.v),
            Center(
              child: InkWell(
                onTap: Get.back,
                child: Text('Cancel',
                    style: CustomTextStyles.partnerCardBody
                        .copyWith(color: appTheme.partnerName)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
