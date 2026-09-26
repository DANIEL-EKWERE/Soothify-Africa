import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/skeleton.dart';
import '../dashboard/controller/expert_dashboard_controller.dart';
import '../widgets/expert_session_card.dart';

/// Every booked session — Figma "Upcoming sessions" (`259:59662`).
///
/// The same card as the dashboard's preview, unlimited: the title at 70, the
/// first card at 116, then a 116 pitch.
class ExpertScheduleTab extends GetView<ExpertDashboardController> {
  const ExpertScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 33.v),
            Text('Upcoming Session', style: CustomTextStyles.appBarTitle),
            SizedBox(height: 24.v),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.load,
                child: Obx(() {
                  if (controller.sessions.isEmpty &&
                      controller.isLoading.value) {
                    return SkeletonShimmer(
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 32.v),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 5,
                        separatorBuilder: (_, _) => SizedBox(height: 8.v),
                        itemBuilder: (_, _) =>
                            const Skeleton(width: 342, height: 108),
                      ),
                    );
                  }
                  if (controller.sessions.isEmpty) {
                    return ListView(
                      padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 32.v),
                      children: [
                        Text('Nothing booked yet.',
                            style: CustomTextStyles.expertCardMeta),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 32.v),
                    itemCount: controller.sessions.length,
                    separatorBuilder: (_, _) => SizedBox(height: 8.v),
                    itemBuilder: (context, i) {
                      final session = controller.sessions[i];
                      return ContentReveal(
                        delay: Duration(milliseconds: 40 * i),
                        child: ExpertSessionCard(
                          session: session,
                          now: controller.now,
                          actionLabel: 'Join call',
                          onAction: () => controller.joinCall(session),
                          onTap: () => controller.openNotes(session),
                        ),
                      );
                    },
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
