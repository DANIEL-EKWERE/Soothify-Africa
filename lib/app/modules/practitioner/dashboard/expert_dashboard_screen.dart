import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/gradient_text.dart';
import '../../../widgets/skeleton.dart';
import '../widgets/expert_money.dart';
import '../widgets/expert_session_card.dart';
import 'controller/expert_dashboard_controller.dart';

/// The expert's home — Figma "Expert dashboard" (`259:59239`).
///
/// Measured below the status bar: a 44 avatar at (24, 88.5) with the greeting
/// beside it from 80, a 44 bell at 321, the earnings card 161 (342x132, the
/// brand gradient, radius 8), "Upcoming Sessions" at 317 with See All, three
/// cards from 354 at a 116 pitch, "Quick Actions" at 722 and two 167x151
/// tiles at 759.
class ExpertDashboardScreen extends GetView<ExpertDashboardController> {
  const ExpertDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: EdgeInsets.fromLTRB(24.h, 33.v, 24.h, 32.v),
            children: [
              const _Greeting(),
              SizedBox(height: 28.5.v),
              const _EarningsCard(),
              SizedBox(height: 28.v),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Upcoming Sessions',
                      style: CustomTextStyles.expertSection),
                  InkWell(
                    onTap: controller.seeAllSessions,
                    child: Text('See All',
                        style: CustomTextStyles.expertSeeAll),
                  ),
                ],
              ),
              SizedBox(height: 16.v),
              const _SessionPreview(),
              SizedBox(height: 28.v),
              Text('Quick Actions', style: CustomTextStyles.expertSection),
              SizedBox(height: 16.v),
              const _QuickActions(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpertDashboardController>();
    return Row(
      children: [
        ClipOval(
          child: CustomImageView(
            imagePath: ImageConstant.imgHomeAvatar,
            height: 44.h,
            width: 44.h,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 7.h),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back,', style: CustomTextStyles.expertGreeting),
              SizedBox(height: 1.v),
              Obx(
                () => GradientText(
                  controller.name.value.isEmpty ? ' ' : controller.name.value,
                  gradient: LinearGradient(
                    colors: [appTheme.soothifyBlue, appTheme.expertIntroInk],
                  ),
                  style: CustomTextStyles.expertName2,
                ),
              ),
              SizedBox(height: 1.v),
              Text('You’re making a real difference.',
                  style: CustomTextStyles.expertGreetingSub),
            ],
          ),
        ),
        SizedBox(width: 8.h),
        InkWell(
          onTap: controller.openNotifications,
          customBorder: const CircleBorder(),
          child: Container(
            width: 44.h,
            height: 44.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: appTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: appTheme.bellBorder, width: 0.5),
            ),
            child: CustomImageView(
              imagePath: ImageConstant.icBell,
              height: 20.h,
              width: 20.h,
              color: appTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// The card is the same `#2C3FE3 -> #142088` the Mood Checker uses, so it
/// takes that gradient rather than defining a second copy of it.
class _EarningsCard extends StatelessWidget {
  const _EarningsCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpertDashboardController>();
    return InkWell(
      onTap: controller.openEarnings,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 132.v,
        padding: EdgeInsets.fromLTRB(16.h, 24.v, 16.h, 16.v),
        decoration: BoxDecoration(
          gradient: appTheme.moodCardGradient,
          borderRadius: BorderRadius.circular(8.h),
        ),
        child: Obx(() {
          final earnings = controller.earnings.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36.h,
                    height: 36.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: appTheme.soothifyBlue.withValues(alpha: 0.64),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 18.h,
                      color: appTheme.onPrimary,
                    ),
                  ),
                  SizedBox(width: 16.h),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Earnings this week',
                            style: CustomTextStyles.expertEarningsCaption),
                        SizedBox(height: 4.v),
                        Text(
                          money(earnings?.thisWeek ?? 0),
                          style: CustomTextStyles.expertEarningsAmount,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(left: 38.h),
                child: Text(
                  earnings == null
                      ? ''
                      : 'Next pay out ${payoutDate(earnings.nextPayout)}',
                  style: CustomTextStyles.expertEarningsCaption,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _SessionPreview extends StatelessWidget {
  const _SessionPreview();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpertDashboardController>();
    return Obx(() {
      if (controller.sessions.isEmpty && controller.isLoading.value) {
        return SkeletonShimmer(
          child: Column(
            children: [
              for (var i = 0; i < 3; i++) ...[
                const Skeleton(width: 342, height: 108),
                SizedBox(height: 8.v),
              ],
            ],
          ),
        );
      }
      if (controller.sessions.isEmpty) {
        return Text('Nothing booked yet.',
            style: CustomTextStyles.expertCardMeta);
      }
      return Column(
        children: [
          for (final session in controller.preview) ...[
            ContentReveal(
              child: ExpertSessionCard(
                session: session,
                now: controller.now,
                actionLabel: 'Join call',
                onAction: () => controller.joinCall(session),
                onTap: () => controller.openNotes(session),
              ),
            ),
            SizedBox(height: 8.v),
          ],
        ],
      );
    });
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpertDashboardController>();
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.calendar_today_outlined,
            title: 'Update Availability',
            body: 'Set your available days and time slots.',
            onTap: controller.openAvailability,
          ),
        ),
        SizedBox(width: 8.h),
        Expanded(
          child: _ActionTile(
            icon: Icons.edit_note_outlined,
            title: 'Add Session Notes',
            body: 'Keep track of your sessions and client progress.',
            onTap: controller.openSessionNotes,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 151.v,
        padding: EdgeInsets.fromLTRB(13.h, 21.v, 13.h, 13.v),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(color: appTheme.textPrimary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.h,
              height: 40.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appTheme.soothifyBlue.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20.h, color: appTheme.soothifyBlue),
            ),
            SizedBox(height: 11.v),
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStyles.expertActionTitle),
            SizedBox(height: 8.v),
            Expanded(
              child: Text(
                body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStyles.expertActionBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
