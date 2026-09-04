import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

/// One of the pill hints under the password field — 24 tall, fully rounded.
///
/// The design draws them in a single resting state; they turn brand blue once
/// the rule is satisfied, so the user can see what is still outstanding
/// instead of being told only on submit.
class PasswordRuleChip extends StatelessWidget {
  const PasswordRuleChip({super.key, required this.label, required this.isMet});

  final String label;
  final bool isMet;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 10.h),
      decoration: BoxDecoration(
        color: isMet
            ? appTheme.soothifyBlue.withValues(alpha: 0.12)
            : appTheme.hintChip,
        borderRadius: BorderRadius.circular(24.h),
      ),
      // No `alignment` here: a Container with one expands to fill the loose
      // constraints Wrap hands it, which would put every chip on its own row.
      child: Text(
        label,
        style: CustomTextStyles.hintChipLabel.copyWith(
          color: isMet ? appTheme.soothifyBlue : appTheme.hintText,
        ),
      ),
    );
  }
}
