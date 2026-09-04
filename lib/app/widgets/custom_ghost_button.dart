import 'package:flutter/material.dart';

import '../core/utils/size_utils.dart';
import '../theme/custom_text_style.dart';
import '../theme/theme_helper.dart';

/// "Ghost / Primary / Full Button / Large" from the design — a full-width
/// outlined button, 52 tall with an 8px radius.
class CustomGhostButton extends StatelessWidget {
  const CustomGhostButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.color,
    this.backgroundColor,
    this.textStyle,
  });

  final String text;
  final VoidCallback? onPressed;
  final double? width;

  /// Outline and label colour. Defaults to the action blue.
  final Color? color;

  /// Fill behind the outline. Defaults to the surface; pass transparent for
  /// the design's "Skip" treatment.
  final Color? backgroundColor;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    // On the charcoal palette the design's near-black outline would disappear,
    // so the accent blue carries the outline in both themes.
    final accent =
        color ?? (appTheme.isDark ? appTheme.soothifyBlue : appTheme.actionFill);

    return SizedBox(
      width: width ?? double.maxFinite,
      height: 52.h,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? appTheme.surface,
          side: BorderSide(color: accent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.h),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: (textStyle ?? CustomTextStyles.buttonLabel)
              .copyWith(color: accent),
        ),
      ),
    );
  }
}
