import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

/// Profile while browsing as a guest — Figma "Profile/unsigned/not logged in"
/// (page 124:2, `176:34542`).
///
/// A blue card carrying three line icons, the pitch and a white Sign up
/// button, with "Unlock Soothify Pro" outlined beneath it. Sign-up is an
/// invitation, not a wall: everything else in the app stays usable.
///
/// The earlier build had the copy and buttons loose on the background; the
/// card, its icons and the glyph inside the button were all missing.
class ProfileUnsigned extends StatelessWidget {
  const ProfileUnsigned({super.key});

  /// Measured off the frame, in points: card top 206 against a header ending
  /// at 86, so 120 of air; card 286 tall; 32 down to the outlined button.
  static const _cardTop = 120.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // The card sits at x=24 where the ListView pads to 22.
      padding: EdgeInsets.symmetric(horizontal: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: _cardTop.v),
          const _SignupCard(),
          SizedBox(height: 32.v),
          _Action(
            // "Unclock" in the frame — a typo for Unlock.
            label: 'Unlock Soothify Pro',
            filled: false,
            onTap: () => Get.toNamed(AppRoutes.shell),
          ),
        ],
      ),
    );
  }
}

class _SignupCard extends StatelessWidget {
  const _SignupCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(22.h, 53.v, 22.h, 51.v),
      decoration: BoxDecoration(
        // Vertical, deep at the top — the same brand pair the auth header
        // uses, running the other way.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [appTheme.brandInk, appTheme.brandLight],
        ),
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Glyph(ImageConstant.imgSignupClock),
              SizedBox(width: 31.h),
              _Glyph(ImageConstant.imgSignupCalendar),
              SizedBox(width: 31.h),
              _Glyph(ImageConstant.imgSignupMind),
            ],
          ),
          SizedBox(height: 23.v),
          Text(
            'Create an account to save your progress and see your stats',
            textAlign: TextAlign.center,
            style: CustomTextStyles.signupPitch,
          ),
          SizedBox(height: 35.v),
          const _SignupButton(),
        ],
      ),
    );
  }
}

class _Glyph extends StatelessWidget {
  const _Glyph(this.path);

  final String path;

  @override
  Widget build(BuildContext context) => CustomImageView(
        imagePath: path,
        height: 36.h,
        width: 36.h,
      );
}

class _SignupButton extends StatelessWidget {
  const _SignupButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.signup),
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 52.v,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: appTheme.onPrimary,
          borderRadius: BorderRadius.circular(8.h),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomImageView(
              imagePath: ImageConstant.icPerson,
              height: 18.h,
              width: 14.h,
            ),
            SizedBox(width: 12.h),
            Text(
              'Sign up',
              style: CustomTextStyles.subscribeLabel.copyWith(
                fontSize: 18.fSize,
                color: appTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 52.v,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? appTheme.actionFill : appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          border: filled ? null : Border.all(color: appTheme.actionFill),
        ),
        child: Text(
          label,
          style: CustomTextStyles.subscribeLabel.copyWith(
            fontSize: 18.fSize,
            color: filled ? appTheme.onPrimary : appTheme.actionFill,
          ),
        ),
      ),
    );
  }
}
