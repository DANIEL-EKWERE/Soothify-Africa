import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/checkin_kind.dart';
import '../controller/profile_tab_controller.dart';

/// The Check-Ins tab — Figma "Profile/mood checkin" (page 124:2,
/// `176:34213`).
///
/// Four identical cards; the design differs only in each badge and heading.
/// Everything in a card is centred, and the card is 246 tall — the earlier
/// build left-aligned the text and drew no badge at all.
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
      // Measured off the frame: badge at 27.5, title 85.5, blurb 112.5,
      // button 162.5 (47.5 tall, inset 43).
      padding: EdgeInsets.symmetric(horizontal: 43.h, vertical: 27.5.v),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: appTheme.optionBorder),
      ),
      child: Column(
        children: [
          CustomImageView(
            imagePath: kind.iconAsset,
            height: 38.h,
            width: 38.h,
          ),
          SizedBox(height: 20.v),
          Text(
            kind.title,
            textAlign: TextAlign.center,
            style: CustomTextStyles.statsHeading,
          ),
          SizedBox(height: 12.v),
          Text(
            kind.blurb,
            textAlign: TextAlign.center,
            style: CustomTextStyles.emptyStateBody,
          ),
          SizedBox(height: 19.v),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8.h),
            child: Container(
              height: 47.5.v,
              width: double.infinity,
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
