import 'package:flutter/material.dart';

import '../core/app_export.dart';
import 'custom_elevated_button.dart';
import 'custom_ghost_button.dart';

/// A yes/no confirmation before something the user cannot walk back.
///
/// The design has no dialog of its own anywhere in the file, so this is the
/// app's: a surface card at the cards' 16 radius, the question in the body
/// ink, and the two actions side by side with the destructive one filled.
///
/// Returns true only when the confirming action is tapped — dismissing by
/// tapping outside returns null, which [confirmed] reads as "no".
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Cancel',
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  static Future<bool> confirmed(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Cancel',
  }) async {
    final answer = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      ),
    );
    return answer ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: appTheme.surface,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.h, 28.v, 24.h, 20.v),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: CustomTextStyles.confirmDialogTitle,
            ),
            SizedBox(height: 12.v),
            Text(
              message,
              textAlign: TextAlign.center,
              style: CustomTextStyles.confirmDialogBody,
            ),
            SizedBox(height: 28.v),
            Row(
              children: [
                Expanded(
                  child: CustomGhostButton(
                    text: cancelLabel,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                SizedBox(width: 12.h),
                Expanded(
                  child: CustomElevatedButton(
                    text: confirmLabel,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
