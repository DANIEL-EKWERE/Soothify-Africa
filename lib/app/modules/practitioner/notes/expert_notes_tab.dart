import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/skeleton.dart';
import '../dashboard/controller/expert_dashboard_controller.dart';
import '../widgets/expert_session_card.dart';

/// The Notes tab.
///
/// The file has no list frame for this: `Session notes | After session`
/// (`259:59854`) is titled after one client, so a session has to be picked
/// before it opens — but nothing draws the picking. This reuses the session
/// card with its action relabelled, which is the smallest thing that can get
/// you there. **Not the design's**; a frame for it would replace this.
class ExpertNotesTab extends GetView<ExpertDashboardController> {
  const ExpertNotesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 33.v),
            Text('Session notes', style: CustomTextStyles.appBarTitle),
            SizedBox(height: 16.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: Text(
                'Keep track of your sessions and client progress, key insight '
                'and next steps.',
                style: CustomTextStyles.expertBlurb,
              ),
            ),
            SizedBox(height: 24.v),
            Expanded(
              child: Obx(() {
                if (controller.sessions.isEmpty && controller.isLoading.value) {
                  return SkeletonShimmer(
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 32.v),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      separatorBuilder: (_, _) => SizedBox(height: 8.v),
                      itemBuilder: (_, _) =>
                          const Skeleton(width: 342, height: 108),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 32.v),
                  itemCount: controller.sessions.length,
                  separatorBuilder: (_, _) => SizedBox(height: 8.v),
                  itemBuilder: (context, i) {
                    final session = controller.sessions[i];
                    return ExpertSessionCard(
                      session: session,
                      now: controller.now,
                      actionLabel: 'Notes',
                      onAction: () => controller.openNotes(session),
                      onTap: () => controller.openNotes(session),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
