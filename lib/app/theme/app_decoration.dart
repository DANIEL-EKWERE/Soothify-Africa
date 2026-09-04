import 'package:flutter/material.dart';

import '../core/utils/size_utils.dart';
import 'theme_helper.dart';

class AppDecoration {
  const AppDecoration._();

  static BoxDecoration get surface => BoxDecoration(color: appTheme.surface);

  /// Mood tile / content card: white on a 5% black hairline, 8px radius.
  static BoxDecoration get card => BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.cardBorder),
      );

  static BoxDecoration get cardSelected => BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.primary, width: 2),
      );

  static BoxDecoration get brandGradient =>
      BoxDecoration(gradient: appTheme.brandGradient);

  static BoxDecoration get onboarding =>
      BoxDecoration(color: appTheme.onboardingSurface);

  static BoxDecoration get pill => BoxDecoration(
        color: appTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(999.h),
      );
}

class BorderRadiusStyle {
  const BorderRadiusStyle._();

  static BorderRadius get small => BorderRadius.circular(8.h);
  static BorderRadius get medium => BorderRadius.circular(12.h);
  static BorderRadius get large => BorderRadius.circular(16.h);
  static BorderRadius get sheet =>
      BorderRadius.vertical(top: Radius.circular(24.h));
}
