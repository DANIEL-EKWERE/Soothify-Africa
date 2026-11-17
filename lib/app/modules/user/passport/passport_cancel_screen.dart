import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app_export.dart';
import '../../../data/models/passport_reservation.dart';
import '../../../data/repositories/spaces_repository.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/soothify_word.dart';

/// "Cancel your reservation?"
///
/// Keeping is the filled button and cancelling the outlined one, which is
/// the frame's own emphasis and the right way round: the destructive answer
/// should not be the one a thumb finds first. Nothing moves until it is
/// confirmed, and the line above the buttons says so.
class PassportCancelScreen extends StatefulWidget {
  const PassportCancelScreen({super.key});

  @override
  State<PassportCancelScreen> createState() => _PassportCancelScreenState();
}

class _PassportCancelScreenState extends State<PassportCancelScreen> {
  bool _working = false;

  PassportReservation? get _held =>
      Get.arguments is PassportReservation
          ? Get.arguments as PassportReservation
          : null;

  Future<void> _cancel() async {
    final held = _held;
    if (held == null || _working) return;
    setState(() => _working = true);
    try {
      await Get.find<SpacesRepository>().cancelReservation(held.id);
      // True, so the Hub knows to re-read the balance rather than guess at
      // it: the class going back is the server's statement, not ours.
      Get.back(result: true);
      AppFeedback.success('passport.cancelled'.tr);
    } on AppException catch (failure) {
      if (mounted) setState(() => _working = false);
      AppFeedback.error(failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final held = _held;
    if (held == null) {
      return Scaffold(
        backgroundColor: appTheme.passportPage,
        body: Center(child: Text('passport.passMissing'.tr)),
      );
    }

    return Scaffold(
      backgroundColor: appTheme.passportPage,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 8.h),
                InkWell(
                  onTap: Get.back,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: EdgeInsets.all(12.h),
                    child: CustomImageView(
                      imagePath: ImageConstant.icBack,
                      height: 24.h,
                      width: 24.h,
                      color: appTheme.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text('passport.cancelTitle'.tr,
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.appBarTitle),
                ),
                SizedBox(width: 48.h),
              ],
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 32.v, 24.h, 24.v),
                children: [
                  Center(
                    child: Container(
                      height: 72.h,
                      width: 72.h,
                      decoration: BoxDecoration(
                        color: appTheme.soothifyBlue.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.event_busy,
                          size: 34.h, color: appTheme.soothifyBlue),
                    ),
                  ),
                  SizedBox(height: 24.v),
                  Text('passport.cancelQuestion'.tr,
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.tierName),
                  SizedBox(height: 12.v),
                  Text('passport.cancelBody'.tr,
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.passportFor),
                  SizedBox(height: 32.v),
                  Container(
                    padding: EdgeInsets.all(16.h),
                    decoration: BoxDecoration(
                      color: appTheme.surface,
                      borderRadius: BorderRadius.circular(12.h),
                      border: Border.all(color: appTheme.cardRim),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.h),
                              child: CustomImageView(
                                imagePath:
                                    held.cover.isEmpty ? null : held.cover,
                                height: 64.h,
                                width: 64.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 16.h),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(held.className,
                                      style: CustomTextStyles.statsHeading),
                                  SizedBox(height: 4.v),
                                  Text(
                                    DateFormat('EEE, d MMM · h:mm a')
                                        .format(held.startsAt),
                                    style: CustomTextStyles.passportFor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.v),
                        Divider(height: 1.v, color: appTheme.cardRim),
                        SizedBox(height: 16.v),
                        Row(
                          children: [
                            Expanded(
                              child: SoothifyText('Soothify Passport',
                                  style: CustomTextStyles.passportFor),
                            ),
                            Text('1 ${'passport.classWord'.tr}',
                                style: CustomTextStyles.statsHeading),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.v),
                  Text('passport.stillBooked'.tr,
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.passportFor),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 24.v),
              child: Column(
                children: [
                  CustomElevatedButton(
                    text: 'passport.keepReservation'.tr,
                    onPressed: _working ? null : Get.back,
                  ),
                  SizedBox(height: 12.v),
                  SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      onTap: _working ? null : _cancel,
                      borderRadius: BorderRadius.circular(8.h),
                      child: Container(
                        height: 52.v,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.h),
                          border: Border.all(color: appTheme.error),
                        ),
                        child: Text(
                          _working
                              ? 'passport.cancelling'.tr
                              : 'passport.cancelAction'.tr,
                          style: CustomTextStyles.subscribeLabel
                              .copyWith(color: appTheme.error),
                        ),
                      ),
                    ),
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
