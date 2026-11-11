import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../data/models/studio_partner.dart';
import 'controller/roster_controller.dart';

/// "Check-in successful" — Figma "5.6 · Check-in successful"
/// (`416:26905`).
///
/// The desk's receipt: who was admitted, to what, and — when the door is
/// working offline — that the check-in is held on the device until it can
/// be filed.
class CheckInDoneScreen extends StatelessWidget {
  const CheckInDoneScreen({super.key});

  static RosterMember? _of(Object? args) =>
      args is RosterMember ? args : null;

  @override
  Widget build(BuildContext context) {
    final member = _of(Get.arguments);
    final roster = Get.isRegistered<RosterController>()
        ? Get.find<RosterController>().roster.value
        : null;
    return Scaffold(
      backgroundColor: appTheme.passportPage,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.v),
            Text('partner.checkInConfirmation'.tr,
                style: CustomTextStyles.partnerCardTitle
                    .copyWith(fontSize: 16.fSize)),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 32.v, 24.h, 24.v),
                children: [
                  Center(
                    child: Container(
                      width: 88.h,
                      height: 88.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: appTheme.partnerOkFill,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded,
                          size: 48.h, color: appTheme.partnerOkInk),
                    ),
                  ),
                  SizedBox(height: 24.v),
                  Text('partner.checkInOk'.tr,
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.partnerSection
                          .copyWith(fontSize: 20.fSize)),
                  SizedBox(height: 8.v),
                  Text(
                    'Passport verified. '
                    '${member?.name.split(' ').first ?? 'The member'} is '
                    'ready for class.',
                    textAlign: TextAlign.center,
                    style: CustomTextStyles.partnerMeta
                        .copyWith(fontSize: 14.fSize),
                  ),
                  SizedBox(height: 24.v),
                  Container(
                    padding: EdgeInsets.all(17.h),
                    decoration: BoxDecoration(
                      color: appTheme.surface,
                      borderRadius: BorderRadius.circular(12.h),
                      border: Border.all(color: appTheme.cardRim),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member?.name ?? '',
                            style: CustomTextStyles.partnerSection),
                        SizedBox(height: 4.v),
                        Text(
                          '${member?.tier ?? ''} · Entry code '
                          '${member?.code ?? ''}',
                          style: CustomTextStyles.partnerMeta,
                        ),
                        SizedBox(height: 14.v),
                        Divider(
                            height: 1,
                            thickness: 1,
                            color: appTheme.cardRim),
                        SizedBox(height: 14.v),
                        Text(roster?.title ?? '',
                            style: CustomTextStyles.partnerCardBody),
                        SizedBox(height: 4.v),
                        Text(roster?.when ?? '',
                            style: CustomTextStyles.partnerMeta),
                        SizedBox(height: 4.v),
                        Text(
                          '${roster?.instructor ?? ''} · '
                          '${roster?.room ?? ''}',
                          style: CustomTextStyles.partnerMeta,
                        ),
                      ],
                    ),
                  ),
                  if (roster?.offline ?? false) ...[
                    SizedBox(height: 16.v),
                    Container(
                      padding: EdgeInsets.all(14.h),
                      decoration: BoxDecoration(
                        color: appTheme.partnerOfflineFill,
                        borderRadius: BorderRadius.circular(10.h),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('partner.savedOnDevice'.tr,
                              style: CustomTextStyles.partnerCardTitle
                                  .copyWith(
                                      color: appTheme.partnerOfflineInk)),
                          SizedBox(height: 4.v),
                          Text(
                            'partner.offlineBody'.tr,
                            style: CustomTextStyles.partnerMeta
                                .copyWith(color: appTheme.partnerOfflineInk),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 24.v),
                  InkWell(
                    onTap: Get.back,
                    borderRadius: BorderRadius.circular(10.h),
                    child: Container(
                      height: 48.v,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: appTheme.soothifyBlue,
                        borderRadius: BorderRadius.circular(10.h),
                      ),
                      child: Text('partner.nextMember'.tr,
                          style: CustomTextStyles.partnerCardTitle
                              .copyWith(color: appTheme.onPrimary)),
                    ),
                  ),
                  SizedBox(height: 10.v),
                  Center(
                    child: InkWell(
                      onTap: Get.back,
                      child: Padding(
                        padding: EdgeInsets.all(8.h),
                        child: Text('partner.backToRoster'.tr,
                            style: CustomTextStyles.partnerCardBody
                                .copyWith(color: appTheme.partnerName)),
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
