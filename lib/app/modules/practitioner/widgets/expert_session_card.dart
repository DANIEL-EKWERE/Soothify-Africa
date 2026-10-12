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
///
/// Both meta rows carry a glyph the card used to omit: a 16 mark for the
/// service (`ph:chats-circle` for therapy, `healthicons:exercise-yoga` for
/// the movement tracks) and a 15 clock before the time, and the action chip
/// opens with a 12 `bi:camera-video`.
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
        // Tighter than the frame's 14/11/13: the bundled NunitoSans
        // sets wider than the design's instance, and "10:30 AM" lost
        // its last letters to an ellipsis at the frame's own insets.
        padding: EdgeInsets.symmetric(horizontal: 12.h),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(color: appTheme.cardRim),
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
            SizedBox(width: 9.h),
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
                  _MetaRow(
                    icon: _serviceIcon(session.service),
                    label: session.service,
                  ),
                  SizedBox(height: 8.v),
                  _MetaRow(
                    icon: Icons.schedule_outlined,
                    label: session.when(now),
                  ),
                ],
              ),
            ),
            SizedBox(width: 4.h),
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 32.v,
                padding: EdgeInsets.symmetric(horizontal: 6.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appTheme.soothifyBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.h),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.videocam_outlined,
                      size: 14.h,
                      color: appTheme.soothifyBlue,
                    ),
                    SizedBox(width: 6.h),
                    Text(actionLabel,
                        style: CustomTextStyles.expertCardAction),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The frame marks the service with a glyph of its own: a speech bubble for
/// the talking tracks, a seated figure for the moving ones.
IconData _serviceIcon(String service) {
  final s = service.toLowerCase();
  if (s.contains('pilates') || s.contains('yoga') || s.contains('stretch')) {
    return Icons.self_improvement_outlined;
  }
  return Icons.chat_bubble_outline;
}

/// One line of card meta: a small glyph, then the words.
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // The frame sets the glyph at 90 and the words at 108 — 3 of gap,
        // not 6. The extra was costing the end of "10:30 AM".
        Icon(icon,
            size: 15.h, color: appTheme.textPrimary.withValues(alpha: 0.8)),
        SizedBox(width: 3.h),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CustomTextStyles.expertCardMeta,
          ),
        ),
      ],
    );
  }
}
