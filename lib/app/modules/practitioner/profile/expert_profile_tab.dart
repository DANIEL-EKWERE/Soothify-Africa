import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/services/session_service.dart';
import '../../../widgets/custom_ghost_button.dart';
import '../dashboard/controller/expert_dashboard_controller.dart';

/// The expert's Profile tab.
///
/// The fifth tab is in the design's nav bar, but **no frame behind it exists**
/// anywhere in the file — the expert row runs dashboard, sessions,
/// availability, notes, calls, earnings and payouts, and stops. So this says
/// what is here rather than inventing a profile, and carries the one action
/// the role genuinely needs today: leaving it.
class ExpertProfileTab extends GetView<ExpertDashboardController> {
  const ExpertProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.h),
          child: Column(
            children: [
              SizedBox(height: 33.v),
              Text('Profile', style: CustomTextStyles.appBarTitle),
              SizedBox(height: 48.v),
              ClipOval(
                child: CustomImageView(
                  imagePath: ImageConstant.imgHomeAvatar,
                  height: 88.h,
                  width: 88.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16.v),
              Obx(
                () => Text(controller.name.value,
                    style: CustomTextStyles.expertSection),
              ),
              SizedBox(height: 32.v),
              Text(
                'The expert profile has no design yet. Your availability, '
                'session notes and earnings are on their own tabs.',
                textAlign: TextAlign.center,
                style: CustomTextStyles.expertCardMeta,
              ),
              const Spacer(),
              CustomGhostButton(
                text: 'Switch role',
                onPressed: () async {
                  await Get.find<SessionService>().signOut();
                  await Get.offAllNamed(AppRoutes.roleSelect);
                },
              ),
              SizedBox(height: 25.v),
            ],
          ),
        ),
      ),
    );
  }
}
