import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// Who the button signs in with.
enum SocialProvider {
  google('Continue with Google'),
  apple('Continue with Apple');

  const SocialProvider(this.label);

  final String label;
}

/// "Continue with …" — the ghost button with the provider's mark inline,
/// 342x52 with an 8px radius.
///
/// One widget for both: this was a `GoogleButton` that an `AppleButton` would
/// have been a copy of, down to the border and the radius.
///
/// Apple's own guidelines ask for a black or white button with their mark at
/// a set size. This follows the design's Google treatment instead, so the two
/// sit together as a pair; worth revisiting before shipping to the App Store.
class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    super.key,
    required this.provider,
    this.onPressed,
  });

  final SocialProvider provider;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.h,
      width: double.maxFinite,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: appTheme.surface,
          side: BorderSide(color: appTheme.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.h),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            switch (provider) {
              SocialProvider.google => Image.asset(
                  ImageConstant.imgGoogle,
                  height: 24.h,
                  width: 24.h,
                ),
              // Material ships the Apple mark, so nothing is drawn by hand
              // and no trademark is redistributed as an asset of ours.
              SocialProvider.apple => Icon(
                  Icons.apple,
                  size: 26.h,
                  color: appTheme.textPrimary,
                ),
            },
            SizedBox(width: 12.h),
            Text(
              provider.label,
              style: CustomTextStyles.secondaryButtonLabel,
            ),
          ],
        ),
      ),
    );
  }
}
