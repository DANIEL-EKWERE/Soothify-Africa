import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/expert_form_fields.dart';
import '../widgets/expert_session_card.dart';
import '../dashboard/controller/expert_dashboard_controller.dart';
import 'controller/session_notes_controller.dart';

/// One session's notes — Figma "Session notes | After session"
/// (`259:59854`).
///
/// Measured: the title at 70, the blurb at 131, the session card at 186, "How
/// did the session go" at 331 with three chips at 358, "Session Summary" at
/// 422 with its box at 451, "Recommendation" at 646 with its box at 675, and
/// "Save" at 1279.
///
/// The frame also carries a "Recommended Content" block at 1033 — the same
/// card the client sees on their Journal tab. It is the *result* of the
/// recommendation the expert writes, so it is not drawn here: nothing has
/// been recommended yet at the point this screen is filled in.
class SessionNotesScreen extends GetView<SessionNotesController> {
  const SessionNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = controller.session;
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 33.v),
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 24.h),
                    child: InkWell(
                      onTap: Get.back,
                      child: CustomImageView(
                        imagePath: ImageConstant.icBack,
                        height: 18.h,
                        width: 18.h,
                        color: appTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                Text(controller.title, style: CustomTextStyles.appBarTitle),
              ],
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 39.v, 24.h, 32.v),
                children: [
                  Text(
                    'Keep track of your sessions and client progress, key '
                    'insight and next steps.',
                    style: CustomTextStyles.expertBlurb,
                  ),
                  SizedBox(height: 26.v),
                  if (session != null)
                    ExpertSessionCard(
                      session: session,
                      now: Get.find<ExpertDashboardController>().now,
                      actionLabel: 'Join call',
                      onAction: () => AppFeedback.info(
                        'Joining the call is not built yet.',
                      ),
                    ),
                  SizedBox(height: 37.v),
                  Text('How did the session go',
                      style: CustomTextStyles.expertSection),
                  SizedBox(height: 16.v),
                  const _OutcomeChips(),
                  SizedBox(height: 33.v),
                  ExpertFormField(
                    label: 'Session Summary',
                    controller: controller.summary,
                    height: 175,
                    maxLines: null,
                  ),
                  SizedBox(height: 33.v),
                  ExpertFormField(
                    label: 'Recommendation',
                    controller: controller.recommendation,
                    height: 175,
                    maxLines: null,
                  ),
                  SizedBox(height: 40.v),
                  CustomElevatedButton(
                    text: 'Save',
                    onPressed: controller.save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Good progress" / "Steady" / "Needs follow-up".
///
/// The frame draws all three in the same resting state, so the chosen
/// treatment is the app's own — the same fill the rest of its option rows use.
class _OutcomeChips extends StatelessWidget {
  const _OutcomeChips();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SessionNotesController>();
    return Obx(
      () => Row(
        children: [
          for (final outcome in SessionOutcome.values) ...[
            GestureDetector(
              onTap: () => controller.choose(outcome),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 30.v,
                padding: EdgeInsets.symmetric(horizontal: 10.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: controller.outcome.value == outcome
                      ? appTheme.actionFill
                      : appTheme.surface,
                  borderRadius: BorderRadius.circular(8.h),
                  border: Border.all(color: appTheme.cardBorder),
                ),
                child: Text(
                  outcome.label,
                  style: CustomTextStyles.expertNoteChip.copyWith(
                    color: controller.outcome.value == outcome
                        ? appTheme.onPrimary
                        : null,
                  ),
                ),
              ),
            ),
            if (outcome != SessionOutcome.values.last) SizedBox(width: 8.h),
          ],
        ],
      ),
    );
  }
}
