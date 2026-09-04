import 'package:flutter/material.dart';

import '../core/utils/size_utils.dart';
import '../theme/custom_text_style.dart';
import '../theme/theme_helper.dart';

/// Full-width primary action button — 52 tall with an 8px radius, per the
/// design's "Filled / Primary / Full button / Large".
///
/// Owns its busy and disabled states so no screen swaps the button out for a
/// spinner, and blocks input while busy to prevent double submission. The
/// disabled fill is the design's own lighter blue, not an opacity fade.
class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.style,
    this.leftIcon,
    this.margin,
    this.width,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ButtonStyle? style;
  final Widget? leftIcon;
  final EdgeInsetsGeometry? margin;
  final double? width;

  bool get _interactive => isEnabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: width ?? double.maxFinite,
      height: 52.h,
      child: ElevatedButton(
        style: style ??
            ElevatedButton.styleFrom(
              backgroundColor:
                  isEnabled ? appTheme.actionFill : appTheme.actionFillDisabled,
              foregroundColor: appTheme.onPrimary,
              disabledBackgroundColor: appTheme.actionFillDisabled,
              disabledForegroundColor: appTheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.h),
              ),
            ),
        onPressed: _interactive ? onPressed : null,
        child: isLoading
            ? SizedBox(
                height: 20.adaptSize,
                width: 20.adaptSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(appTheme.onPrimary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leftIcon != null) ...[
                    leftIcon!,
                    SizedBox(width: 8.h),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyles.buttonLabel,
                    ),
                  ),
                ],
              ),
      ),
    );

    return margin == null ? button : Padding(padding: margin!, child: button);
  }
}
