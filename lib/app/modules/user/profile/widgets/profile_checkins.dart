import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/checkin_kind.dart';
import '../controller/profile_tab_controller.dart';

/// The Check-Ins tab — Figma "Profile/mood checkin" (135:8202).
///
/// Four identical cards; the design differs only in each heading.
class ProfileCheckins extends StatelessWidget {
  const ProfileCheckins({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileTabController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final kind in CheckinKind.values) ...[
          _CheckinCard(kind: kind, onTap: () => controller.openCheckin(kind)),
          SizedBox(height: 32.v),
        ],
      ],
    );
  }
}

class _CheckinCard extends StatelessWidget {
  const _CheckinCard({required this.kind, required this.onTap});

  final CheckinKind kind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 24.v),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: appTheme.optionBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kind.title, style: CustomTextStyles.statsHeading),
          SizedBox(height: 5.v),
          Text(kind.blurb, style: CustomTextStyles.emptyStateBody),
          SizedBox(height: 26.v),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8.h),
            child: Container(
              height: 44.v,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appTheme.actionFill,
                borderRadius: BorderRadius.circular(8.h),
              ),
              child: Text(
                'Get Started',
                style: CustomTextStyles.subscribeLabel
                    .copyWith(fontSize: 16.fSize),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
