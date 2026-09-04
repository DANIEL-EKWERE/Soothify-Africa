import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// "Continue with Google" — the ghost button with the Google mark inline,
/// 342x52 with an 8px radius.
class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, this.onPressed});

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
            Image.asset(ImageConstant.imgGoogle, height: 24.h, width: 24.h),
            SizedBox(width: 12.h),
            Text(
              'Continue with Google',
              style: CustomTextStyles.secondaryButtonLabel,
            ),
          ],
        ),
      ),
    );
  }
}
