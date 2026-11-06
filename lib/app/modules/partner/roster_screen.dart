import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../data/models/studio_partner.dart';
import 'controller/roster_controller.dart';
import 'widgets/dispute_dialog.dart';
import 'widgets/partner_chrome.dart';

/// The door — Figma "5.3 · Live roster & verification" (`416:26667`), with
/// its error state (`416:26744`) and the banner it wears once provisional
/// entry has been granted (`416:26850`).
///
/// One screen in three states rather than three screens: the class summary
/// and the roster beneath never change, and only the middle panel does.
class RosterScreen extends GetView<RosterController> {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.passportPage,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.v),
            Row(
              children: [
                SizedBox(width: 24.h),
                InkWell(
                  onTap: Get.back,
                  customBorder: const CircleBorder(),
                  child: CustomImageView(
                    imagePath: ImageConstant.icChevronLeft,
                    height: 24.h,
                    width: 24.h,
                    color: appTheme.textPrimary,
                  ),
                ),
                Expanded(
                  child: Text('Live roster & verification',
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.partnerCardTitle
                          .copyWith(fontSize: 16.fSize)),
                ),
                SizedBox(width: 48.h),
              ],
            ),
            Expanded(
              child: Obx(() {
                final roster = controller.roster.value;
                final failure = controller.failure.value;
                final granted = controller.granted.value;
                return RefreshIndicator(
                  onRefresh: controller.load,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(24.h, 20.v, 24.h, 32.v),
                    children: [
                      if (roster != null) _ClassSummary(roster: roster),
                      SizedBox(height: 20.v),
                      if (granted != null) ...[
                        _GrantedBanner(member: granted),
                        SizedBox(height: 20.v),
                      ] else if (roster?.offline ?? false) ...[
                        const _OfflineBanner(),
                        SizedBox(height: 20.v),
                      ],
                      if (failure != null)
                        _Failure(failure: failure)
                      else
                        const _Verification(),
                      SizedBox(height: 20.v),
                      if (roster != null) _RosterTable(roster: roster),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// The class being worked, at the top of every state.
class _ClassSummary extends StatelessWidget {
  const _ClassSummary({required this.roster});

  final StudioRoster roster;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(17.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 5.v),
            decoration: BoxDecoration(
              color: categoryWash(roster.category),
              borderRadius: BorderRadius.circular(8.h),
            ),
            child: Text(roster.category.label,
                style: CustomTextStyles.partnerStatus
                    .copyWith(color: appTheme.textPrimary)),
          ),
          SizedBox(height: 12.v),
          Text(roster.title,
              style: CustomTextStyles.partnerSection
                  .copyWith(fontSize: 20.fSize)),
          SizedBox(height: 10.v),
          Text(roster.when, style: CustomTextStyles.partnerCardBody),
          SizedBox(height: 8.v),
          Text('${roster.instructor} · ${roster.room}',
              style: CustomTextStyles.partnerMeta
                  .copyWith(fontSize: 14.fSize)),
          SizedBox(height: 12.v),
          Row(
            children: [
              Expanded(
                child: Text('${roster.bookings} Passport bookings',
                    style: CustomTextStyles.partnerStatus
                        .copyWith(color: appTheme.soothifyBlue)),
              ),
              Text('${roster.slotsOpen} slots open',
                  style: CustomTextStyles.partnerMeta),
            ],
          ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.h),
      decoration: BoxDecoration(
        color: appTheme.partnerOfflineFill,
        borderRadius: BorderRadius.circular(10.h),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Offline Mode Active',
              style: CustomTextStyles.partnerCardTitle
                  .copyWith(color: appTheme.partnerOfflineInk)),
          SizedBox(height: 4.v),
          Text('Check-ins will sync automatically when reconnected.',
              style: CustomTextStyles.partnerMeta
                  .copyWith(color: appTheme.partnerOfflineInk)),
        ],
      ),
    );
  }
}

/// The banner after provisional entry — `416:26850`.
class _GrantedBanner extends StatelessWidget {
  const _GrantedBanner({required this.member});

  final RosterMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.h),
      decoration: BoxDecoration(
        color: appTheme.partnerOkFill,
        borderRadius: BorderRadius.circular(10.h),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Entry granted to ${member.name}',
              style: CustomTextStyles.partnerCardTitle
                  .copyWith(color: appTheme.partnerOkInk)),
          SizedBox(height: 4.v),
          Text('Report sent to admin log · Code Expired',
              style: CustomTextStyles.partnerMeta
                  .copyWith(color: appTheme.partnerOkInk)),
        ],
      ),
    );
  }
}

/// "Front desk verification" — the scanner, the code, and the button.
class _Verification extends StatelessWidget {
  const _Verification();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RosterController>();
    return Container(
      padding: EdgeInsets.all(17.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Front desk verification',
              style: CustomTextStyles.partnerSection),
          SizedBox(height: 14.v),
          InkWell(
            onTap: controller.scan,
            borderRadius: BorderRadius.circular(10.h),
            child: Container(
              height: 48.v,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appTheme.soothifyBlue,
                borderRadius: BorderRadius.circular(10.h),
              ),
              child: Text('Scan Passport QR Code',
                  style: CustomTextStyles.partnerCardTitle
                      .copyWith(color: appTheme.onPrimary)),
            ),
          ),
          SizedBox(height: 12.v),
          Text(
            'Or use the member’s entry code if the network or camera fails.',
            style: CustomTextStyles.partnerMeta,
          ),
          SizedBox(height: 14.v),
          Text('Member entry code',
              style: CustomTextStyles.partnerStatus
                  .copyWith(color: appTheme.textPrimary)),
          SizedBox(height: 8.v),
          Container(
            height: 52.v,
            padding: EdgeInsets.symmetric(horizontal: 13.h),
            decoration: BoxDecoration(
              color: appTheme.surface,
              borderRadius: BorderRadius.circular(10.h),
              border: Border.all(color: appTheme.fieldRim),
            ),
            child: Center(
              child: TextField(
                controller: controller.entryCode,
                onChanged: (_) => controller.touch(),
                textCapitalization: TextCapitalization.characters,
                style: CustomTextStyles.partnerSection
                    .copyWith(fontSize: 20.fSize),
                cursorColor: appTheme.soothifyBlue,
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'STH-89A',
                  hintStyle: CustomTextStyles.partnerSection.copyWith(
                    fontSize: 20.fSize,
                    color: appTheme.partnerMuted,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.v),
          Text('Enter the 6-character code; the hyphen is automatic.',
              style: CustomTextStyles.partnerMeta
                  .copyWith(fontSize: 11.fSize)),
          SizedBox(height: 14.v),
          Obx(
            () => InkWell(
              onTap: controller.canVerify ? controller.verify : null,
              borderRadius: BorderRadius.circular(10.h),
              child: Container(
                height: 48.v,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appTheme.surface,
                  borderRadius: BorderRadius.circular(10.h),
                  border: Border.all(
                    color: controller.canVerify
                        ? appTheme.passportAction
                        : appTheme.cardRim,
                  ),
                ),
                child: controller.verifying.value
                    ? SizedBox(
                        height: 18.h,
                        width: 18.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.h,
                          color: appTheme.passportAction,
                        ),
                      )
                    : Text('Verify Entry Code',
                        style: CustomTextStyles.partnerCardTitle.copyWith(
                          color: controller.canVerify
                              ? appTheme.passportAction
                              : appTheme.partnerMuted,
                        )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Check-in unsuccessful" — `416:26744`.
class _Failure extends StatelessWidget {
  const _Failure({required this.failure});

  final CheckInOutcome failure;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RosterController>();
    final member = failure.member;
    return Container(
      padding: EdgeInsets.all(17.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline,
                  size: 20.h, color: appTheme.partnerWarnInk),
              SizedBox(width: 8.h),
              Text('Check-in unsuccessful',
                  style: CustomTextStyles.partnerSection),
            ],
          ),
          SizedBox(height: 10.v),
          Text(failure.problem, style: CustomTextStyles.partnerMeta),
          if (member != null) ...[
            SizedBox(height: 14.v),
            Text('${member.name} · ${member.tier}',
                style: CustomTextStyles.partnerCardBody),
            SizedBox(height: 4.v),
            Text('Entry code: ${member.code}',
                style: CustomTextStyles.partnerMeta),
          ],
          SizedBox(height: 16.v),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: controller.retry,
                  borderRadius: BorderRadius.circular(10.h),
                  child: Container(
                    height: 48.v,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: appTheme.surface,
                      borderRadius: BorderRadius.circular(10.h),
                      border: Border.all(color: appTheme.cardRim),
                    ),
                    child: Text('Try Again',
                        style: CustomTextStyles.partnerCardTitle
                            .copyWith(color: appTheme.soothifyBlue)),
                  ),
                ),
              ),
              SizedBox(width: 10.h),
              Expanded(
                child: InkWell(
                  onTap: member == null
                      ? null
                      : () => showDisputeDialog(context),
                  borderRadius: BorderRadius.circular(10.h),
                  child: Container(
                    height: 48.v,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: appTheme.soothifyBlue,
                      borderRadius: BorderRadius.circular(10.h),
                    ),
                    child: Text('Dispute Check in',
                        style: CustomTextStyles.partnerCardTitle
                            .copyWith(color: appTheme.onPrimary)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.v),
          Text(
            'Grant entry now. The issue will be sent to the admin log for '
            'review.',
            style: CustomTextStyles.partnerMeta
                .copyWith(fontSize: 11.fSize),
          ),
        ],
      ),
    );
  }
}

/// "Passport members" and who is through the door.
class _RosterTable extends StatelessWidget {
  const _RosterTable({required this.roster});

  final StudioRoster roster;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RosterController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Passport members',
                  style: CustomTextStyles.partnerSection),
            ),
            Text('${roster.bookings} booked',
                style: CustomTextStyles.partnerMeta),
          ],
        ),
        SizedBox(height: 12.v),
        Container(
          height: 36.v,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: appTheme.partnerOkFill,
            borderRadius: BorderRadius.circular(8.h),
          ),
          child: Text(
            // Once somebody is provisional the plain count stops being
            // true, so the fuller line replaces it.
            roster.provisional > 0
                ? controller.admittedSummary
                : controller.arrivalSummary,
            style: CustomTextStyles.partnerStatus
                .copyWith(color: appTheme.partnerOkInk),
          ),
        ),
        SizedBox(height: 12.v),
        Container(
          padding: EdgeInsets.all(14.h),
          decoration: BoxDecoration(
            color: appTheme.surface,
            borderRadius: BorderRadius.circular(12.h),
            border: Border.all(color: appTheme.cardRim),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text('Member Name',
                        style: CustomTextStyles.partnerMeta
                            .copyWith(fontSize: 11.fSize)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('Tier Tag',
                        style: CustomTextStyles.partnerMeta
                            .copyWith(fontSize: 11.fSize)),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text('Check-in Status',
                        textAlign: TextAlign.right,
                        style: CustomTextStyles.partnerMeta
                            .copyWith(fontSize: 11.fSize)),
                  ),
                ],
              ),
              SizedBox(height: 10.v),
              for (final member in roster.members) ...[
                Divider(height: 1, thickness: 1, color: appTheme.cardRim),
                SizedBox(height: 10.v),
                _MemberRow(member: member),
                SizedBox(height: 10.v),
              ],
            ],
          ),
        ),
        if (roster.unsynced > 0) ...[
          SizedBox(height: 10.v),
          Text(
            '${roster.unsynced} check-ins saved on this device · Pending '
            'sync',
            style: CustomTextStyles.partnerMeta
                .copyWith(fontSize: 11.fSize),
          ),
        ],
      ],
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member});

  final RosterMember member;

  @override
  Widget build(BuildContext context) {
    final (fill, ink) = switch (member.status) {
      StudioVerification.verified => (
          appTheme.partnerOkFill,
          appTheme.partnerOkInk,
        ),
      StudioVerification.provisional => (
          appTheme.partnerWarnFill,
          appTheme.partnerWarnInk,
        ),
      StudioVerification.notArrived => (
          appTheme.partnerTabTrack,
          appTheme.partnerMuted,
        ),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(member.name, style: CustomTextStyles.partnerCardBody),
        ),
        Expanded(
          flex: 3,
          child: Text(member.tier, style: CustomTextStyles.partnerMeta),
        ),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.h, vertical: 4.v),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(8.h),
                ),
                child: Text(member.status.label,
                    style: CustomTextStyles.partnerStatus
                        .copyWith(fontSize: 10.fSize, color: ink)),
              ),
              if (member.at != null) ...[
                SizedBox(height: 4.v),
                Text(
                  member.status == StudioVerification.provisional
                      ? 'Entry granted · ${_clock(member.at!)}'
                      : _clock(member.at!),
                  style: CustomTextStyles.partnerMeta
                      .copyWith(fontSize: 10.fSize),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static String _clock(DateTime at) {
    final hour = at.hour % 12 == 0 ? 12 : at.hour % 12;
    final minute = at.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${at.hour < 12 ? 'AM' : 'PM'}';
  }
}
