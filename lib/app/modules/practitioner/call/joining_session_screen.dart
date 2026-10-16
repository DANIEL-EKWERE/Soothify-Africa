import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/expert_session.dart';
import '../../../widgets/custom_ghost_button.dart';
import '../widgets/expert_header.dart';
import 'controller/joining_session_controller.dart';
import 'widgets/joining_pulse.dart';

/// The expert joining a booked call — Figma "Joining session" (`259:59996`).
///
/// Measured: the title at 70, the blurb at 109, three concentric discs from
/// 164.8 (152.5, 119.1 and 77 across), "Joining Call" at 334, its line at
/// 372, a two-column detail row at 445, a green panel 342x64 at 519, two 36
/// controls at 613 with labels at 661, and "Cancel" at 702.
///
/// The frame's title reads "Session in Progess" and its hint "in a quite
/// space for  the best experience" — both corrected.
class JoiningSessionScreen extends GetView<JoiningSessionController> {
  const JoiningSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = controller.session;
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 33.v),
            const ExpertHeader(title: 'Session in Progress'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 17.v, 24.h, 24.v),
                children: [
                  Text('You’re joining a live session with your client.',
                      style: CustomTextStyles.expertBlurb),
                  SizedBox(height: 33.v),
                  const Center(child: JoiningPulse()),
                  SizedBox(height: 36.v),
                  Text('Joining Call',
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.joiningHeading),
                  SizedBox(height: 16.v),
                  Text(
                    // The frame's line here is the payout flow's — "Your
                    // payout details have been saved successfully. You'll now
                    // receive your earnings based on your selected method." —
                    // pasted onto a call screen. This one is the app's, and
                    // says only what is true.
                    'Hold on while we connect you. Your client joins as soon '
                    'as the call opens.',
                    textAlign: TextAlign.center,
                    style: CustomTextStyles.joiningBody,
                  ),
                  SizedBox(height: 16.v),
                  if (session != null) _Details(session: session),
                  SizedBox(height: 37.v),
                  const _QuietHint(),
                  SizedBox(height: 30.v),
                  const _CallControls(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 25.v),
              // Outlined: Cancel is the way out of this screen, not the
              // thing it is for.
              child: CustomGhostButton(
                text: 'Cancel',
                onPressed: controller.cancel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Who and when — the frame's pale blue card: the client's portrait, their
/// name and service, a hairline, then a calendar and the session's hours.
///
/// It was drawing two bare columns of text: no portrait, no rule, no
/// calendar, and no card behind them.
class _Details extends StatelessWidget {
  const _Details({required this.session});

  final ExpertSession session;

  @override
  Widget build(BuildContext context) {
    // The hours are the session's own, so "now" is its start: this screen is
    // opened at the appointment, and a real clock would make the label drift
    // to "Sep 28" the day before.
    final at = session.startsAt;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 14.v),
      decoration: BoxDecoration(
        color: appTheme.policyPanel,
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipOval(
            child: CustomImageView(
              imagePath: session.avatarAsset,
              height: 40.h,
              width: 40.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 11.h),
          Expanded(
            child: _Field(
              // The frame writes "Client".
              caption: 'Client',
              value: session.clientName,
              detail: session.service,
            ),
          ),
          // The hairline the frame sets between the two halves.
          Container(width: 1, height: 55.v, color: appTheme.sessionCardRule),
          SizedBox(width: 13.h),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2.v),
                  child: CustomImageView(
                    imagePath: ImageConstant.icCalendarSmall,
                    height: 19.h,
                    width: 19.h,
                  ),
                ),
                SizedBox(width: 8.h),
                Expanded(
                  child: _Field(
                    // The frame writes "Seesion Time".
                    caption: 'Session Time',
                    // Start to end, which is what the frame prints.
                    value: session.hours,
                    detail: _date(at),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _date(DateTime at) =>
      '${ExpertSessionMonth.of(at.month)} ${at.day} ${at.year}';
}

/// The frame prints "Sep 28 2026" — no comma.
extension ExpertSessionMonth on DateTime {
  static String of(int month) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][month - 1];
}

class _Field extends StatelessWidget {
  const _Field({
    required this.caption,
    required this.value,
    required this.detail,
  });

  final String caption;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(caption, style: CustomTextStyles.joiningCaption),
        SizedBox(height: 4.v),
        // Two lines allowed: "10:00 AM - 11:00 AM" wraps in the narrower
        // column rather than ellipsising to "11:0…".
        Text(value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: CustomTextStyles.joiningValue),
        SizedBox(height: 4.v),
        Text(detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CustomTextStyles.joiningCaption),
      ],
    );
  }
}

class _QuietHint extends StatelessWidget {
  const _QuietHint();

  @override
  Widget build(BuildContext context) {
    // A shield at the left with the words beside it, both ranged left — the
    // frame's arrangement. This was centred, with no shield and a rim the
    // frame does not draw.
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.h, 16.v, 16.h, 16.v),
      decoration: BoxDecoration(
        color: appTheme.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomImageView(
            imagePath: ImageConstant.icSecurity,
            height: 20.h,
            width: 20.h,
          ),
          SizedBox(width: 16.h),
          Expanded(
            child: Text(
              // The frame writes "in a quite space for  the best experience".
              'Make sure you’re in a quiet space for the best experience.',
              style: CustomTextStyles.joiningHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _CallControls extends StatelessWidget {
  const _CallControls();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JoiningSessionController>();
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
              // Light grey, not the 4% a card takes: these are 36 circles
              // on the background, and at a card's weight the ring vanished.
              border: Border.all(color: appTheme.fieldRim),
            ),
            child: Icon(icon, size: 18.h, color: appTheme.textPrimary),
          ),
          SizedBox(height: 12.v),
          Text(label, style: CustomTextStyles.joiningControl),
        ],
      ),
    );
  }
}
