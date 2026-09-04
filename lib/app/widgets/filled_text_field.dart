import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// The auth screens' input: a 14px caption, then a 344x48 filled box with a
/// 4px radius and a faint hairline. Matches Figma 655:6109 and siblings.
class FilledTextField extends StatelessWidget {
  const FilledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.hintText,
    this.suffix,
    this.hasError = false,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? hintText;
  final Widget? suffix;

  /// Draws the border in the error colour; the message itself is rendered by
  /// the screen, as the design places it below the field.
  final bool hasError;

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: CustomTextStyles.inputLabel),
        SizedBox(height: 8.h),
        Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 12.h),
          decoration: BoxDecoration(
            color: appTheme.fieldFill,
            borderRadius: BorderRadius.circular(4.h),
            border: Border.all(
              color: hasError ? appTheme.error : appTheme.rowBorder,
              width: hasError ? 1 : 0.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  textCapitalization: textCapitalization,
                  onChanged: onChanged,
                  style: CustomTextStyles.optionLabel,
                  cursorColor: appTheme.soothifyBlue,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false,
                    hintText: hintText,
                    hintStyle: CustomTextStyles.optionLabel.copyWith(
                      color: appTheme.hintText,
                    ),
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              ?suffix,
            ],
          ),
        ),
      ],
    );
  }
}
