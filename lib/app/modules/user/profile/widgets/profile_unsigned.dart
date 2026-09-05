import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

/// Profile while browsing as a guest — Figma "Profile/unsigned/not logged in"
/// (135:8494).
///
/// The stats card is meaningless without an account, so the tab offers to
/// create one instead. Sign-up is an invitation here, not a wall: everything
/// else in the app stays usable.
class ProfileUnsigned extends StatelessWidget {
  const ProfileUnsigned({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 90.v),
        Text(
          // The frame's copy runs past its box; "stats" is the reading the
          // visible text supports. Worth confirming.
          'Create an account to save your progress\nand see your stats',
          textAlign: TextAlign.center,
          style: CustomTextStyles.emptyStateBody,
        ),
        SizedBox(height: 44.v),
        _Action(
          label: 'Sign up or Log in',
          filled: true,
          onTap: () => Get.toNamed(AppRoutes.signup),
        ),
        SizedBox(height: 32.v),
        _Action(
          // "Unclock" in the frame — a typo for Unlock.
          label: 'Unlock Soothify Pro',
          filled: false,
          onTap: () => Get.toNamed(AppRoutes.shell),
        ),
      ],
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
