import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/app_notification.dart';
import '../../../widgets/gradient_text.dart';
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
                    separatorBuilder: (_, _) => SizedBox(height: 30.v),
                    itemBuilder: (context, i) => _Entry(
                      notification: items[i],
                      now: controller.now,
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
    return Padding(
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
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      f.label,
                      style: selected
                          ? CustomTextStyles.notificationChipSelected
                          : CustomTextStyles.notificationChip,
                    ),
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
        NotificationKind.reminder => _ReminderCard(notification: notification),
        NotificationKind.digest => _Digest(notification: notification),
        NotificationKind.plain => _Plain(notification: notification, now: now),
        NotificationKind.action => _Action(notification: notification, now: now),
      };
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
            height: 28.h,
            width: 28.h,
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

/// The one outlined entry in the frame.
class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.h, 9.v, 10.h, 11.v),
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
                SizedBox(width: 9.h),
              ],
              // Navy line art, cropped from a light-mode frame — tinted so
              // it does not disappear against the dark palette.
              CustomImageView(
                imagePath: notification.iconAsset,
                height: 21.h,
                width: 21.h,
                color: appTheme.brandInk,
              ),
              SizedBox(width: 10.h),
              Text(
                notification.title,
                style: CustomTextStyles.notificationCardTitle,
              ),
            ],
          ),
          SizedBox(height: 18.v),
          Text.rich(
            TextSpan(
              style: CustomTextStyles.notificationText,
              children: [
                TextSpan(text: notification.actor),
                TextSpan(
                  text: notification.text,
                  style: CustomTextStyles.notificationActor,
                ),
                TextSpan(text: notification.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The weekly digest — headed, with its body centred and no border.
class _Digest extends StatelessWidget {
  const _Digest({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (notification.unread) ...[
              const _UnreadDot(),
              SizedBox(width: 12.h),
            ],
            CustomImageView(
              imagePath: notification.iconAsset,
              height: 22.h,
              width: 22.h,
              color: appTheme.brandInk,
            ),
            SizedBox(width: 13.h),
            Expanded(
              child: Text(
                notification.title,
                style: CustomTextStyles.notificationDigestTitle,
              ),
            ),
          ],
        ),
        SizedBox(height: 20.v),
        Text(
          notification.body,
          textAlign: TextAlign.center,
          style: CustomTextStyles.notificationText,
        ),
      ],
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
