import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/care_concern.dart';
import '../../../widgets/custom_elevated_button.dart';
import 'controller/care_support_controller.dart';

/// "Care support" — Figma `280:26747`, with `280:26775` as its sent state.
///
/// Measured: a 24-square chevron at (24, 69) with the title centred beside
/// it; a 72.7 `#E2EDFE` disc centred at (194.5, 211) holding a 51 flower
/// glyph; the heading at 274.5 and its note at 312.5, both 308 wide and
/// centred; four 342x48 rows from 372.5 at a 64 pitch; the action at 660.5;
/// and a 12pt reassurance at 738.
///
/// **The frame draws the sent state over the form with no panel behind it**
/// — the option rows show through the confirmation text. Read as the
/// designer leaving the form layers visible rather than as a transparent
/// dialog, so this replaces the form instead of covering it.
class CareSupportScreen extends GetView<CareSupportController> {
  const CareSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 22.v),
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
                      'Care support',
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.appBarTitle,
                    ),
                  ),
                  SizedBox(width: 24.h),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView(
                  padding: EdgeInsets.fromLTRB(24.h, 73.v, 24.h, 24.v),
                  children: [
                    const _Crest(),
                    SizedBox(height: 28.v),
                    Text(
                      'We are here to protect your peace',
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.careSupportHeading,
                    ),
                    SizedBox(height: 16.v),
                    Text(
                      'Tell us what happened. Your feedback is private and '
                      'handled with care.',
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.careSupportNote,
                    ),
                    SizedBox(height: 28.v),
                    if (controller.sent.value)
                      const _Sent()
                    else
                      const _Form(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Crest extends StatelessWidget {
  const _Crest();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 72.7.h,
        width: 72.7.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: appTheme.careCrest,
          shape: BoxShape.circle,
        ),
        child: CustomImageView(
          imagePath: ImageConstant.icFlower,
          height: 50.9.h,
          width: 50.9.h,
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CareSupportController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final concern in controller.concerns) ...[
          _ConcernRow(
            concern: concern,
            selected: controller.isSelected(concern),
            onTap: () => controller.choose(concern),
          ),
          SizedBox(height: 16.v),
        ],
        SizedBox(height: 60.v),
        CustomElevatedButton(
          text: 'Send to Support Team',
          isEnabled: controller.canSend,
          onPressed: controller.send,
        ),
        SizedBox(height: 25.5.v),
        Text(
          'Your feedback is completely private and handled with care by our '
          'support team.',
          textAlign: TextAlign.center,
          style: CustomTextStyles.careSupportFootnote,
        ),
      ],
    );
  }
}

class _ConcernRow extends StatelessWidget {
  const _ConcernRow({
    required this.concern,
    required this.selected,
    required this.onTap,
  });

  final CareConcern concern;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 48.v,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 13.h),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          // The frame outlines the chosen row in brand blue and the rest in
          // the body ink.
          border: Border.all(
            color: selected ? appTheme.soothifyBlue : appTheme.textPrimary,
          ),
        ),
        child: Text.rich(
          TextSpan(
            text: concern.label,
            style: CustomTextStyles.careConcern,
            children: [
              if (concern.hint.isNotEmpty)
                TextSpan(
                  text: concern.hint,
                  style: CustomTextStyles.careConcernHint,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `280:26775` — what the screen says once the report is away.
class _Sent extends StatelessWidget {
  const _Sent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 32.v),
        Text(
          // The frame's string carries a trailing space.
          'We’ve Got You',
          textAlign: TextAlign.center,
          style: CustomTextStyles.careSentTitle,
        ),
        SizedBox(height: 16.v),
        Text(
          'Your care concern has been sent safely to our support team. It’s '
          'completely confidential, and someone will reach out within 24 '
          'hours to make sure you feel supported.',
          textAlign: TextAlign.center,
          style: CustomTextStyles.careSentBody,
        ),
        SizedBox(height: 16.v),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.5.h),
          child: CustomElevatedButton(
            text: 'Return to Session',
            height: 39,
            onPressed: Get.back,
          ),
        ),
      ],
    );
  }
}
