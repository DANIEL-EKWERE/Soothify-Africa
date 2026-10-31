import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/session_mode.dart';

/// "How do you want to have your sessions?" — Figma `259:38702`.
///
/// The design asks this once, inside the therapy questionnaire, and the
/// answer went nowhere: every booking was sent as a video call whatever
/// was chosen, and the Pilates & Core and Stretch & Restore flows never
/// asked at all. It is a step of the booking now, so the answer reaches
/// the session it is about.
///
/// Answers with the chosen [SessionMode], or null if backed out — the
/// booking is made by the caller, so leaving here books nothing.
/// "How would you like to connect with your wellness coach?" — the
/// Schedule frame: two square cards side by side, a phone and a camcorder.
///
/// Choosing is the whole screen; there is no Continue button, because a
/// card is the answer. Answers with the chosen [SessionMode], or null if
/// backed out — the booking is made by the caller, so leaving here books
/// nothing.
class SessionModeScreen extends StatelessWidget {
  const SessionModeScreen({super.key, this.initial});

  /// What they chose last time, drawn as already selected.
  final SessionMode? initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 18.v),
              Row(
                children: [
                  InkWell(
                    onTap: Get.back,
                    child: CustomImageView(
                      imagePath: ImageConstant.icBack,
                      height: 18.h,
                      width: 18.h,
                      color: appTheme.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Schedule',
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.appBarTitle
                          .copyWith(color: appTheme.brandDeep),
                    ),
                  ),
                  // Balances the back arrow so the title sits centred.
                  SizedBox(width: 18.h),
                ],
              ),
              SizedBox(height: 60.v),
              Text(
                'How would you like to\nconnect with your wellness coach?',
                style: CustomTextStyles.breatheHeading
                    .copyWith(color: appTheme.brandDeep),
              ),
              SizedBox(height: 12.v),
              Text(
                'We want to make sure it\u2019s a comfortable and convenient '
                'experience for you.',
                style: CustomTextStyles.emptyStateBody,
              ),
              SizedBox(height: 40.v),
              Row(
                children: [
                  for (final mode in SessionMode.values) ...[
                    Expanded(
                      child: _ModeCard(
                        mode: mode,
                        selected: initial == mode,
                        onTap: () => Get.back<SessionMode>(result: mode),
                      ),
                    ),
                    if (mode != SessionMode.values.last) SizedBox(width: 20.h),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One square card — the icon over its label, as the frame draws it.
class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final SessionMode mode;

  /// Their last choice. The frame outlines both cards the same; this only
  /// thickens the one they picked before, so returning here shows it.
  final bool selected;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.h),
      child: AspectRatio(
        // Square, as drawn.
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: appTheme.surface,
            borderRadius: BorderRadius.circular(12.h),
            border: Border.all(
              color: appTheme.soothifyBlue,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomImageView(
                imagePath: mode.icon,
                height: 34.h,
                width: 34.h,
                color: appTheme.soothifyBlue,
              ),
              SizedBox(height: 14.v),
              Text(
                mode.cardLabel,
                textAlign: TextAlign.center,
                style: CustomTextStyles.emptyStateBody
                    .copyWith(color: appTheme.brandDeep),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
