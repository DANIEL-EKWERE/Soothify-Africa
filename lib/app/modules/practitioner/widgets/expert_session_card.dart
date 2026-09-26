import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/expert_session.dart';

/// A booked session, from the expert's side — Figma "Expert dashboard"
/// (`259:59239`) and "Upcoming sessions" (`259:59662`), which draw the same
/// card at the same size.
///
/// Measured: 342x108, radius 8, white inside a 1px `#263238` hairline; a 41
/// avatar inset 14, the client's name at 21 from the card top, the service at
/// 47, the time at 71, and an action chip 79x32 at (274, 38) filled with the
/// action blue at 8%.
class ExpertSessionCard extends StatelessWidget {
  const ExpertSessionCard({
    super.key,
    required this.session,
    required this.now,
    required this.actionLabel,
    required this.onAction,
    this.onTap,
  });

  final ExpertSession session;

  /// Pinned by the caller so "Today, 10:00 AM" cannot go stale mid-screen.
  final DateTime now;

  /// "Join call" on the dashboard and Schedule; the Notes tab asks for
  /// something else.
  final String actionLabel;

  final VoidCallback onAction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 108.v,
        padding: EdgeInsets.symmetric(horizontal: 14.h),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(color: appTheme.textPrimary),
        ),
        child: Row(
          children: [
            ClipOval(
              child: CustomImageView(
                imagePath: session.avatarAsset,
                height: 41.h,
                width: 41.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 11.h),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.clientName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles.expertCardName,
                  ),
                  SizedBox(height: 8.v),
                  Text(
                    session.service,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles.expertCardMeta,
                  ),
                  SizedBox(height: 8.v),
                  Text(
                    session.when(now),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles.expertCardMeta,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.h),
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 32.v,
                padding: EdgeInsets.symmetric(horizontal: 12.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appTheme.soothifyBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.h),
                ),
                child: Text(actionLabel,
                    style: CustomTextStyles.expertCardAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
