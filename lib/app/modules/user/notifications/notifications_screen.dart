import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/app_notification.dart';
import '../../../widgets/gradient_text.dart';
import '../../../widgets/skeleton.dart';
import 'controller/notifications_controller.dart';

/// The notification feed — Figma "Notification" (page 124:2, `176:24737`).
///
/// The frame mixes its rows on purpose: a bare line with an avatar, an
/// outlined Reminder card, a headed digest block with centred body copy, and
/// two plain lines — one of them carrying a "Read" link instead of an avatar.
/// Each shape is a [NotificationKind]; the list renders whichever it is given.
///
/// A second frame in the file (`176:36688`) puts every entry in an identical
/// card. This is the one that was asked for.
///
/// Measured below the status bar: header 36, chips 99 (20 tall), first row
/// 148. Content margin 24.
class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 36.v),
            const _Header(),
            SizedBox(height: 41.v),
            const _Filters(),
            SizedBox(height: 29.v),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.load,
                child: Obx(() {
                  final items = controller.visible;
                  if (items.isEmpty && controller.isLoading.value) {
                    return SkeletonShimmer(
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 32.v),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 6,
                        separatorBuilder: (_, _) => SizedBox(height: 30.v),
                        itemBuilder: (_, _) => Row(
                          children: [
                            const Skeleton(
                                width: 28, height: 28, radius: 14),
                            SizedBox(width: 16.h),
                            const Skeleton.text(width: 180),
                            const Spacer(),
                            const Skeleton.text(width: 60, height: 10),
                          ],
                        ),
                      ),
                    );
                  }
                  if (items.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(height: 80.v),
                        Text(
                          'Nothing here yet.',
                          textAlign: TextAlign.center,
                          style: CustomTextStyles.emptyStateBody,
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 32.v),
                    itemCount: items.length,
                    // 16 between every row, whatever shape either one is —
                    // the frame's eight entries sit on a uniform pitch.
                    separatorBuilder: (_, _) => SizedBox(height: 16.v),
                    itemBuilder: (context, i) => ContentReveal(
                      delay: Duration(milliseconds: 45 * i),
                      child: _Entry(
                        notification: items[i],
                        now: controller.now,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Row(
        children: [
          InkWell(
            onTap: Get.back,
            child: CustomImageView(
              imagePath: ImageConstant.icBack,
              height: 18.h,
              width: 18.h,
              color: appTheme.textPrimary,
            ),
          ),
          Expanded(
            child: GradientText(
              'Notification',
              textAlign: TextAlign.center,
              gradient: appTheme.titleGradient,
              style: CustomTextStyles.notificationTitle,
            ),
          ),
          CustomImageView(
            imagePath: ImageConstant.icBell,
            height: 22.h,
            width: 22.h,
            color: appTheme.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();
    // Three chips now, and they fit 342 across — the row still scrolls so a
    // large system text scale cannot clip the last one.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Row(
        children: [
          for (final f in NotificationFilter.values) ...[
            Obx(() {
              final selected = controller.filter.value == f;
              return InkWell(
                onTap: () => controller.select(f),
                borderRadius: BorderRadius.circular(10.h),
                // No `alignment` on the chip's own box — with one set it
                // expands to the row instead of hugging its label.
                child: Container(
                  height: 20.v,
                  padding: EdgeInsets.symmetric(horizontal: 11.h),
                  decoration: BoxDecoration(
                    color: selected
                        ? appTheme.soothifyBlue
                        : appTheme.transparent,
                    borderRadius: BorderRadius.circular(10.h),
                    border: selected
                        ? null
                        : Border.all(color: appTheme.chipOutline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        f.label,
                        style: selected
                            ? CustomTextStyles.notificationChipSelected
                            : CustomTextStyles.notificationChip,
                      ),
                      if (f.badge) ...[
                        SizedBox(width: 6.h),
                        // Accent rather than the brand blue: the chip itself
                        // turns blue when selected, and a blue tag on blue
                        // would vanish.
                        Container(
                          height: 14.v,
                          padding: EdgeInsets.symmetric(horizontal: 5.h),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: appTheme.accent,
                            borderRadius: BorderRadius.circular(7.h),
                          ),
                          child: Text('New',
                              style: CustomTextStyles.notificationChipBadge),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
            SizedBox(width: 11.h),
          ],
        ],
      ),
    );
  }
}

/// Dispatches on the entry's shape.
class _Entry extends StatelessWidget {
  const _Entry({required this.notification, required this.now});

  final AppNotification notification;
  final DateTime now;

  @override
  Widget build(BuildContext context) => switch (notification.kind) {
        NotificationKind.social => _Social(notification: notification, now: now),
        NotificationKind.recommendation =>
          _Recommendation(notification: notification),
        // The frame gives "Reminder" the same pill as a booking row.
        NotificationKind.reminder => _Booking(notification: notification),
        NotificationKind.digest => _Digest(notification: notification),
        NotificationKind.plain => _Plain(notification: notification, now: now),
        NotificationKind.action ||
        NotificationKind.breathe =>
          _Action(notification: notification, now: now),
        NotificationKind.booking => _Booking(notification: notification),
      };
}

/// A compact outlined pill — Figma `259:61271`.
///
/// Measured: 342x39, radius 8, a `#999999` hairline, an 8 unread dot 7 in,
/// the kind at 37 and the line at 90, both centred in the row's height.
class _Booking extends StatelessWidget {
  const _Booking({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 39.v,
      // The frame's own body box is 233 for a 47-character line — right at
      // its limit. The gaps are trimmed from its 30 and 8 so the sentence
      // lands whole rather than at "…at 5:00p…".
      padding: EdgeInsets.only(left: 7.h, right: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.notificationCardBorder),
      ),
      child: Row(
        children: [
          if (notification.unread)
            Container(
              width: 8.h,
              height: 8.h,
              decoration: BoxDecoration(
                color: appTheme.unreadDot,
                shape: BoxShape.circle,
              ),
            )
          else
            SizedBox(width: 8.h),
          SizedBox(width: 14.h),
          Text(notification.title,
              style: CustomTextStyles.notificationBookingKind),
          SizedBox(width: 6.h),
          Expanded(
            child: _BookingLine(notification: notification),
          ),
        ],
      ),
    );
  }
}

/// A booking line with its discipline in bold.
///
/// `259:61271` sets the discipline — "Yoga", "Pilates & Core" — in Nunito
/// Bold inside an otherwise regular sentence, in the same ink. It was shipping
/// flat.
class _BookingLine extends StatelessWidget {
  const _BookingLine({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final parts = splitEmphasis(notification);
    final base = CustomTextStyles.notificationBookingBody;
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: parts.before),
          if (parts.bold.isNotEmpty)
            TextSpan(
              text: parts.bold,
              style: CustomTextStyles.notificationBookingEmphasis,
            ),
          if (parts.after.isNotEmpty) TextSpan(text: parts.after),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// The bold actor and the rest of the line, sharing one baseline.
TextSpan _line(AppNotification n) => TextSpan(
      style: CustomTextStyles.notificationText,
      children: [
        if (n.actor.isNotEmpty)
          TextSpan(text: n.actor, style: CustomTextStyles.notificationActor),
        TextSpan(text: n.text),
      ],
    );

class _Social extends StatelessWidget {
  const _Social({required this.notification, required this.now});

  final AppNotification notification;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: CustomImageView(
            imagePath: notification.avatarAsset,
            height: 39.h,
            width: 39.h,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 16.h),
        Expanded(
          child: Text.rich(
            _line(notification),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 6.h),
        Text(
          notification.ago(now),
          style: CustomTextStyles.notificationTime,
        ),
      ],
    );
  }
}

/// The card the feed opens with — Figma `259:26851`, 342x77.
///
/// Measured from the card's own box: avatar 39 at (10, 7), the bold heading
/// at x=59 over two lines, the body at x=60 and y=46. The unread dot sits
/// *on* the avatar's top-left corner, where the frame leaves it — every other
/// row puts it at x=8, and here the avatar was dropped over that spot.
class _Recommendation extends StatelessWidget {
  const _Recommendation({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.h, 7.v, 10.h, 7.v),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.notificationCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipOval(
                child: CustomImageView(
                  imagePath: notification.avatarAsset,
                  height: 39.h,
                  width: 39.h,
                  fit: BoxFit.cover,
                ),
              ),
              if (notification.unread)
                Positioned(left: 2.h, top: 2.h, child: const _UnreadDot()),
            ],
          ),
          SizedBox(width: 10.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: CustomTextStyles.notificationDigestTitle,
                ),
                SizedBox(height: 11.v),
                Text(
                  notification.body,
                  style: CustomTextStyles.notificationCardBody,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The weekly digest — Figma `259:26851`, a 342x62 outline.
///
/// It shipped borderless with centred body copy; the frame gives it the same
/// hairline as the other cards and sets the body flush left.
class _Digest extends StatelessWidget {
  const _Digest({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8.h, 7.v, 8.h, 7.v),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.notificationCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (notification.unread) ...[
                const _UnreadDot(),
                SizedBox(width: 3.h),
              ],
              CustomImageView(
                imagePath: notification.iconAsset,
                height: 22.h,
                width: 22.h,
                color: appTheme.brandInk,
              ),
              SizedBox(width: 3.h),
              Expanded(
                child: Text(
                  notification.title,
                  style: CustomTextStyles.notificationDigestTitle,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.v),
          Padding(
            padding: EdgeInsets.only(left: 36.h),
            child: Text(
              notification.body,
              style: CustomTextStyles.notificationCardBody,
            ),
          ),
        ],
      ),
    );
  }
}

class _Plain extends StatelessWidget {
  const _Plain({required this.notification, required this.now});

  final AppNotification notification;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text.rich(
            _line(notification),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 21.h),
        Text(
          notification.ago(now),
          style: CustomTextStyles.notificationTime,
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.notification, required this.now});

  final AppNotification notification;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();
    return Row(
      children: [
        Flexible(
          child: Text(
            notification.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CustomTextStyles.notificationText,
          ),
        ),
        SizedBox(width: 24.h),
        InkWell(
          onTap: () => controller.openAction(notification),
          child: GradientText(
            notification.actionLabel,
            gradient: appTheme.titleGradient,
            style: CustomTextStyles.notificationText,
          ),
        ),
        SizedBox(width: 23.h),
        Text(
          notification.ago(now),
          style: CustomTextStyles.notificationTime,
        ),
      ],
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) => Container(
        height: 7.5.h,
        width: 7.5.h,
        decoration: BoxDecoration(
          color: appTheme.unreadDot,
          shape: BoxShape.circle,
        ),
      );
}
