import 'package:flutter/material.dart';

import '../core/utils/size_utils.dart';
import 'theme_helper.dart';

class CustomButtonStyles {
  const CustomButtonStyles._();

  static ButtonStyle get primary => ElevatedButton.styleFrom(
        backgroundColor: appTheme.primary,
        foregroundColor: appTheme.onPrimary,
        elevation: 0,
        minimumSize: Size.fromHeight(52.v),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.h)),
      );

  static ButtonStyle get secondary => ElevatedButton.styleFrom(
        backgroundColor: appTheme.surface,
        foregroundColor: appTheme.brandInk,
        elevation: 0,
        minimumSize: Size.fromHeight(52.v),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.h)),
      );

  static ButtonStyle get ghost => TextButton.styleFrom(
        foregroundColor: appTheme.primary,
        minimumSize: Size.fromHeight(48.v),
      );
}
