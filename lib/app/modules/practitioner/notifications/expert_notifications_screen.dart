import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/expert_notification.dart';
import '../../../widgets/filter_pill.dart';
import 'controller/expert_notifications_controller.dart';

/// The expert's notification feed.
///
/// Three chips and a list of outlined pills: a booking, then the reminders
/// that follow it. The same [FilterPill] the client's feed uses, because the
/// design draws one control.
///
/// A note in the dashboard controller used to say this frame was a client
/// screen filed in the wrong row, on the evidence of its nav bar. The live
/// file draws it with the expert's bar, so it is this role's after all.
class ExpertNotificationsScreen
    extends GetView<ExpertNotificationsController> {
  const ExpertNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 33.v),
            Padding(
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
                    child: Text(
                      'Notification',
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.appBarTitle
                          .copyWith(color: appTheme.brandDeep),
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
            ),
            SizedBox(height: 24.v),
            SizedBox(
              height: 30.v,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 24.h),
                children: [
                  for (final f in ExpertNotificationFilter.values) ...[
                    Obx(
                      () => FilterPill(
                        label: f.label,
                        selected: controller.filter.value == f,
                        onTap: () => controller.select(f),
                      ),
                    ),
                    if (f != ExpertNotificationFilter.values.last)
                      SizedBox(width: 8.h),
                  ],
                ],
              ),
            ),
            SizedBox(height: 24.v),
            Expanded(
              child: Obx(
                () => ListView(
                  padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 32.v),
                  children: [
                    for (final item in controller.visible) ...[
                      _Row(item: item),
                      SizedBox(height: 12.v),
                    ],
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

class _Row extends StatelessWidget {
  const _Row({required this.item});

  final ExpertNotification item;

  @override
  Widget build(BuildContext context) {
    final split = item.body.split(item.emphasis);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 14.v),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(8.h),
        // 4% black — a card on white takes a hairline.
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CustomImageView(
                imagePath: item.kind == ExpertNotificationKind.booking
                    ? ImageConstant.icCalendarOutline
                    : ImageConstant.icNoteEdit,
                height: 22.h,
                width: 22.h,
                color: appTheme.soothifyBlue,
              ),
              if (item.unread)
                Positioned(
                  top: -3.v,
                  left: -3.h,
                  child: Container(
                    width: 8.h,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: appTheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 12.h),
          Text(item.kind.label, style: CustomTextStyles.expertRowLabel),
          SizedBox(width: 10.h),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: CustomTextStyles.expertCardMeta,
                children: [
                  TextSpan(text: split.first),
                  TextSpan(
                    text: item.emphasis,
                    style: CustomTextStyles.expertRowLabel,
                  ),
                  if (split.length > 1) TextSpan(text: split.last),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
