import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/app_export.dart';
import '../../../data/models/passport_reservation.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/soothify_word.dart';

/// The pass itself — "Your space is saved" and "View details".
///
/// One screen for both frames, because they are the same pass with a
/// different frame around it: the first is the receipt the reservation ends
/// on, the second is that pass looked up again from the Hub. [justBooked]
/// is what differs — the green disc and its two buttons, against a title
/// and a single way back.
///
/// The QR encodes the entry code and nothing else. It is what the studio's
/// scanner reads, and the code is printed beneath it for the times the
/// scanner will not play — which is the case the partner's own screen is
/// built around.
class PassportPassScreen extends StatelessWidget {
  const PassportPassScreen({super.key});

  static PassportReservation? _of(Object? args) =>
      args is PassportReservation ? args : null;

  /// The receipt arrives with the reservation just made; the Hub sends the
  /// same object back when the pass is opened again.
  static bool _isReceipt(Object? args) =>
      args is Map && args['justBooked'] == true;

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final held = _of(args is Map ? args['reservation'] : args);
    final justBooked = _isReceipt(args);

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
            if (!justBooked) _Header(title: 'passport.viewDetails'.tr),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 24.v, 24.h, 24.v),
                children: [
                  if (justBooked) ...[
                    SizedBox(height: 40.v),
                    Center(
                      child: Container(
                        height: 96.h,
                        width: 96.h,
                        decoration: BoxDecoration(
                          color: appTheme.success,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check,
                            size: 52.h, color: appTheme.onPrimary),
                      ),
                    ),
                    SizedBox(height: 24.v),
                    Text('passport.spaceSaved'.tr,
                        textAlign: TextAlign.center,
                        style: CustomTextStyles.tierName),
                    SizedBox(height: 8.v),
                    Text('passport.breatheDeep'.tr,
                        textAlign: TextAlign.center,
                        style: CustomTextStyles.passportFor),
                    SizedBox(height: 32.v),
                  ] else ...[
                    _ClassCard(held: held),
                    SizedBox(height: 16.v),
                  ],
                  _PassCard(held: held, justBooked: justBooked),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 24.v),
              child: justBooked
                  ? Column(
                      children: [
                        CustomElevatedButton(
                          text: 'common.done'.tr,
                          onPressed: () =>
                              Get.until((r) => Get.currentRoute == AppRoutes.shell),
                        ),
                        SizedBox(height: 8.v),
                        TextButton(
                          onPressed: () =>
                              Get.offNamed(AppRoutes.passportHub),
                          child: Text('passport.viewInReservations'.tr,
                              style: CustomTextStyles.subscribeLabel
                                  .copyWith(color: appTheme.soothifyBlue)),
                        ),
                      ],
                    )
                  : CustomElevatedButton(
                      text: 'passport.backToPlans'.tr,
                      onPressed: Get.back,
                    ),
            ),
          ],
        ),
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
          child: Text(title,
              textAlign: TextAlign.center,
              style: CustomTextStyles.appBarTitle),
        ),
        SizedBox(width: 48.h),
      ],
    );
  }
}

/// What was booked — the detail frame's first card.
class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.held});

  final PassportReservation held;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  imagePath: held.cover.isEmpty ? null : held.cover,
                  height: 64.h,
                  width: 64.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(held.className,
                        style: CustomTextStyles.statsHeading),
                    SizedBox(height: 4.v),
                    Text(
                      DateFormat('EEE, d MMM · h:mm a').format(held.startsAt),
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
    );
  }
}

/// The pass: the code, as a square and as six characters.
class _PassCard extends StatelessWidget {
  const _PassCard({required this.held, required this.justBooked});

  final PassportReservation held;
  final bool justBooked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Column(
        children: [
          if (!justBooked) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 6.v),
              decoration: BoxDecoration(
                color: appTheme.success.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16.h),
              ),
              child: Text('passport.confirmed'.tr,
                  style: CustomTextStyles.expertCardMeta
                      .copyWith(color: appTheme.success)),
            ),
            SizedBox(height: 16.v),
            Text('passport.yourQr'.tr,
                style: CustomTextStyles.statsHeading),
            SizedBox(height: 4.v),
            Text('passport.showAtStudio'.tr,
                textAlign: TextAlign.center,
                style: CustomTextStyles.passportFor),
            SizedBox(height: 20.v),
          ],
          // White behind it always: a dark surface under a QR is a QR that
          // will not scan, and this one is read off a phone at a counter.
          Container(
            padding: EdgeInsets.all(12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12.h),
            ),
            child: QrImageView(
              data: held.code,
              version: QrVersions.auto,
              size: justBooked ? 140.h : 200.h,
              backgroundColor: const Color(0xFFFFFFFF),
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF111111),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF111111),
              ),
            ),
          ),
          SizedBox(height: 16.v),
          if (justBooked) ...[
            Text(held.spaceName, style: CustomTextStyles.statsHeading),
            SizedBox(height: 4.v),
            Text(
              '${held.className} · '
              '${DateFormat('EEE h:mm a').format(held.startsAt)}',
              textAlign: TextAlign.center,
              style: CustomTextStyles.passportFor,
            ),
            SizedBox(height: 12.v),
            Text('passport.showAtDesk'.tr,
                textAlign: TextAlign.center,
                style: CustomTextStyles.passportFor),
            SizedBox(height: 4.v),
          ],
          Text(
            '${'passport.checkInCode'.tr}: ${held.codeLabel}',
            style: CustomTextStyles.statsHeading,
          ),
        ],
      ),
    );
  }
}
