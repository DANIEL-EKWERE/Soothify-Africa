import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../practitioner/call/widgets/joining_pulse.dart';
import 'controller/client_joining_controller.dart';

/// The client joining a booked session — Figma `280:26643`, new in the
/// redrawn "Book a licensed Expert" section.
///
/// The practitioner's twin is `lib/app/modules/practitioner/call/`; the two
/// differ in whose details they show and in the Cancel button, which is
/// outlined here and filled there.
///
/// Measured: the title at 70, the lead line at 109, the pulse from 155.8, the
/// "Joining Call" heading at 325, a 342x98 `#EDF6FE` detail card at 451, a
/// 342x126 safe-space panel at 557, the two controls at 713 with their labels
/// at 761, and the action at 810.
///
/// **The frame prints the Care Guarantee paragraph twice** — once bare under
/// "Joining Call" and again inside the titled panel — the same paste slip the
/// practitioner frame has. It appears once here, under the heading that makes
/// sense of it.
class ClientJoiningScreen extends GetView<ClientJoiningController> {
  const ClientJoiningScreen({super.key});

  static const String guarantee =
      'All sessions booked through Soothify are protected under our Care '
      'Guarantee. Staying inside your Soothify space ensures your privacy '
      'remains encrypted, your payments are secure, and your support is '
      'guaranteed';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 23.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: Get.back,
                    child: CustomImageView(
                      imagePath: ImageConstant.icBack,
                      height: 24.h,
                      width: 24.h,
                      color: appTheme.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      // The frame reads "Session in Progess".
                      'Session in Progress',
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.appBarTitle,
                    ),
                  ),
                  SizedBox(width: 24.h),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 17.v, 24.h, 24.v),
                children: [
                  Text('You’re joining a live session...',
                      style: CustomTextStyles.clientJoiningLead),
                  SizedBox(height: 24.v),
                  const Center(child: JoiningPulse()),
                  SizedBox(height: 36.v),
                  Text('Joining Call',
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.joiningHeading),
                  SizedBox(height: 32.v),
                  const _SessionCard(),
                  SizedBox(height: 32.v),
                  const _SafeSpacePanel(),
                  SizedBox(height: 30.v),
                  const _Controls(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 32.v),
              child: CustomElevatedButton(
                text: 'Cancel',
                // Outlined, unlike the practitioner's filled Cancel.
                style: ElevatedButton.styleFrom(
                  backgroundColor: appTheme.surface,
                  foregroundColor: appTheme.actionFill,
                  elevation: 0,
                  side: BorderSide(color: appTheme.actionFill),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.h),
                  ),
                ),
                labelStyle: CustomTextStyles.studioSecondaryAction,
                onPressed: controller.cancel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Who and when — a 342x98 card on the palest blue.
class _SessionCard extends StatelessWidget {
  const _SessionCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientJoiningController>();
    return Container(
      height: 98.v,
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      decoration: BoxDecoration(
        color: appTheme.policyPanel,
        borderRadius: BorderRadius.circular(8.h),
      ),
      child: Row(
        children: [
          CustomImageView(
            imagePath: ImageConstant.imgCoachPhoto,
            height: 40.h,
            width: 40.h,
            fit: BoxFit.cover,
            radius: BorderRadius.circular(20.h),
          ),
          SizedBox(width: 11.h),
          Expanded(
            child: _Field(
              label: 'Expert',
              value: controller.expertName,
              note: controller.service,
            ),
          ),
          Expanded(
            child: _Field(
              // The frame reads "Seesion Time".
              label: 'Session Time',
              value: controller.time,
              note: controller.date,
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, required this.note});

  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: CustomTextStyles.sessionFieldLabel),
        SizedBox(height: 4.v),
        Text(value, style: CustomTextStyles.sessionFieldValue),
        SizedBox(height: 4.v),
        Text(note, style: CustomTextStyles.sessionFieldLabel),
      ],
    );
  }
}

/// "Your Safe Space is Protected" — the Care Guarantee, once.
class _SafeSpacePanel extends StatelessWidget {
  const _SafeSpacePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.h, 16.v, 16.h, 16.v),
      decoration: BoxDecoration(
        color: appTheme.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.textPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomImageView(
                imagePath: ImageConstant.icSecurity,
                height: 20.h,
                width: 20.h,
              ),
              SizedBox(width: 16.h),
              Text('Your Safe Space is Protected',
                  style: CustomTextStyles.careGuaranteeTitle),
            ],
          ),
          SizedBox(height: 8.v),
          Padding(
            padding: EdgeInsets.only(left: 36.h),
            child: Text(ClientJoiningScreen.guarantee,
                style: CustomTextStyles.careGuaranteeItem),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientJoiningController>();
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Control(
            icon: controller.micOn.value
                ? Icons.mic_none
                : Icons.mic_off_outlined,
            label: controller.micOn.value ? 'Mute Mic' : 'Unmute Mic',
            onTap: controller.toggleMic,
          ),
          SizedBox(width: 84.h),
          _Control(
            icon: controller.cameraOn.value
                ? Icons.videocam_outlined
                : Icons.videocam_off_outlined,
            label: controller.cameraOn.value
                ? 'Turn Off Camera'
                : 'Turn On Camera',
            onTap: controller.toggleCamera,
          ),
        ],
      ),
    );
  }
}

class _Control extends StatelessWidget {
  const _Control({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.h,
            height: 36.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: appTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: appTheme.textBlack),
            ),
            child: Icon(icon, size: 18.h, color: appTheme.textPrimary),
          ),
          SizedBox(height: 12.v),
          Text(label, style: CustomTextStyles.callControlLabel),
        ],
      ),
    );
  }
}
