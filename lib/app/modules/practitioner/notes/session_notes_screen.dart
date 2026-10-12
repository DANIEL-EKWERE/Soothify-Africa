import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/expert_content_card.dart';
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
/// The frame then draws the recommended content at 854 — the same card the
/// client sees on their Journal tab — a repeat of the opening line beneath
/// it, and Save at 1267.
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
                    // No chip on this frame: the session is over, so there
                    // is no call to join. The third line carries the service
                    // and the hours rather than the day.
                    ExpertSessionCard(
                      session: session,
                      now: Get.find<ExpertDashboardController>().now,
                      timeLabel: '${session.service} * ${session.hours}',
                      showTimeIcon: false,
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
                    // The frame writes the same prompt into both boxes.
                    hint: 'How did the session go? Add notes about the '
                        'client’s progress, key topics discussed, '
                        'observations or next steps',
                  ),
                  SizedBox(height: 33.v),
                  ExpertFormField(
                    label: 'Recommendation',
                    controller: controller.recommendation,
                    height: 175,
                    maxLines: null,
                    hint: 'How did the session go? Add notes about the '
                        'client’s progress, key topics discussed, '
                        'observations or next steps',
                  ),
                  SizedBox(height: 21.v),
                  Obx(() {
                    final content = controller.content.value;
                    if (content == null) return const SizedBox.shrink();
                    return ExpertContentCard(
                      content: content,
                      onOpen: controller.openContent,
                      // The notes frame leaves the cover clean and crops it
                      // shallower than the journal's.
                      showPlayOverlay: false,
                      coverHeight: 116,
                      actionLabel: 'Watch Video',
                    );
                  }),
                  SizedBox(height: 27.v),
                  Text(
                    'Keep track of your sessions and client progress, key '
                    'insight and next steps.',
                    style: CustomTextStyles.expertCardMeta,
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
                  // The frame fills the chosen chip with the same amber its
                  // auth CTA uses, not with the app's action blue, and the
                  // chip it fills carries no rim.
                  color: controller.outcome.value == outcome
                      ? appTheme.authAccent
                      : appTheme.surface,
                  borderRadius: BorderRadius.circular(8.h),
                  border: controller.outcome.value == outcome
                      ? null
                      : Border.all(color: appTheme.cardRim),
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
