import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/membership.dart';
import '../../../widgets/custom_ghost_button.dart';
import 'controller/trial_offer_controller.dart';
import '../../../widgets/soothify_word.dart';

/// "Subscription pop up 1" — Figma `311:25655`, which replaced the pair of
/// pop-ups at `259:59011` and `259:58598` on 2026-10-05.
///
/// Measured below the status bar: "Restore purchase" at 74.5, the title at
/// 129, the blurb at 171 across 300, the three-step timeline at 237 (64
/// tall), the annual card at 311 (342x108), the monthly one at 427 (342x70),
/// the due-today row at 513, three benefit lines from 551 on a 36 pitch, the
/// action at 734 and the footer at 802.
class TrialOfferScreen extends GetView<TrialOfferController> {
  const TrialOfferScreen({super.key});

  /// The frame's own three steps.
  static const List<(String, String)> timeline = [
    ('Today', 'Full access'),
    ('Day 5', 'Reminder sent'),
    ('Day 7', 'Billing starts'),
  ];

  static const List<int> timelineFlex = [102, 122, 116];

  static const List<String> benefits = [
    'Expert-led yoga & Pilates classes on demand',
    'New classes added weekly - practice anywhere, anytime.',
    'Culturally inclusive wellness with local language support',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 27.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: controller.restorePurchase,
                  child: Text(
                    'Restore purchase',
                    style: CustomTextStyles.trialRestore,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 34.v, 24.h, 0),
                children: [
                  Text(
                    '7 days, on us.',
                    textAlign: TextAlign.center,
                    style: CustomTextStyles.trialTitle,
                  ),
                  SizedBox(height: 21.v),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 21.h),
                    child: SoothifyText(
                      'Every class on Soothify, free for a week. Cancel '
                      'anytime before day 7.',
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.trialBody,
                    ),
                  ),
                  SizedBox(height: 24.v),
                  const _Timeline(),
                  SizedBox(height: 10.v),
                  for (final plan in MembershipPlan.values) ...[
                    Obx(() => _PlanCard(
                          plan: plan,
                          chosen: controller.plan.value == plan,
                        )),
                    SizedBox(height: 8.v),
                  ],
                  SizedBox(height: 8.v),
                  Obx(() => _DueToday(
                        due: controller.dueToday,
                        renews: '${controller.firstChargeDate.substring(0, 3)} '
                            '9, 2026 · ${controller.firstCharge} / yr',
                      )),
                  SizedBox(height: 22.v),
                  for (final benefit in benefits) ...[
                    _Benefit(label: benefit),
                    SizedBox(height: 18.v),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: Column(
                children: [
                  // The frame makes this a ghost button, not a filled one.
                  CustomGhostButton(
                    text: 'Start My Free Week',
                    color: appTheme.soothifyBlue,
                    onPressed: controller.openPayment,
                  ),
                  SizedBox(height: 16.v),
                  Text(
                    'No charge today · Secure checkout',
                    textAlign: TextAlign.center,
                    style: CustomTextStyles.trialFootnote,
                  ),
                  SizedBox(height: 28.v),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Today → Day 5 → Day 7, so the week is legible before it starts.
class _Timeline extends StatelessWidget {
  const _Timeline();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64.v,
      child: Row(
        children: [
          for (var i = 0; i < TrialOfferScreen.timeline.length; i++) ...[
            Expanded(
              flex: TrialOfferScreen.timelineFlex[i],
              child: Container(
                padding: EdgeInsets.fromLTRB(13.h, 13.v, 8.h, 8.v),
                decoration: BoxDecoration(
                  color: appTheme.surface,
                  borderRadius: BorderRadius.circular(8.h),
                  border: Border.all(color: appTheme.cardHairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TrialOfferScreen.timeline[i].$1,
                      style: CustomTextStyles.trialStep.copyWith(
                        // Only the step you are on is in the brand blue.
                        color: i == 0
                            ? appTheme.soothifyBlue
                            : appTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.v),
                    Text(
                      TrialOfferScreen.timeline[i].$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyles.trialStepBody,
                    ),
                  ],
                ),
              ),
            ),
            if (i < TrialOfferScreen.timeline.length - 1)
              SizedBox(width: 8.h),
          ],
        ],
      ),
    );
  }
}

/// The annual card carries the brand gradient and its tick; the monthly one
/// is a plain outlined row.
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.chosen});

  final MembershipPlan plan;
  final bool chosen;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrialOfferController>();
    final onGradient = plan.hasSaving;
    return InkWell(
      onTap: () => controller.choosePlan(plan),
      borderRadius: BorderRadius.circular(16.h),
      child: Container(
        padding: EdgeInsets.fromLTRB(24.h, 16.v, 24.h, 16.v),
        decoration: BoxDecoration(
          gradient: onGradient ? appTheme.brandGradient : null,
          color: onGradient ? null : appTheme.surface,
          borderRadius: BorderRadius.circular(16.h),
          border: onGradient
              ? null
              : Border.all(
                  color: chosen ? appTheme.soothifyBlue : appTheme.cardHairline,
                ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (plan.offerSaving.isNotEmpty) ...[
                    // Aligned, not stretched: a Container with an alignment
                    // and no width fills whatever it is given, so the pill
                    // ran the whole width of the card instead of hugging its
                    // own label.
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        // No height and no alignment: either one makes a
                        // Container fill the width it is offered, which is
                        // what had the pill running the whole card. The
                        // padding sizes it to its own label instead.
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.h, vertical: 3.v),
                        decoration: BoxDecoration(
                          color: appTheme.onPrimary,
                          borderRadius: BorderRadius.circular(8.h),
                        ),
                        child: Text(
                          plan.offerSaving,
                          style: CustomTextStyles.trialSavingBadge,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.v),
                  ],
                  Text(
                    plan.offerTitle,
                    style: CustomTextStyles.trialPlanTitle.copyWith(
                      color: onGradient
                          ? appTheme.onPrimary
                          : appTheme.textPrimary,
                    ),
                  ),
                  if (plan.offerSub.isNotEmpty) ...[
                    SizedBox(height: 2.v),
                    Text(
                      plan.offerSub,
                      style: CustomTextStyles.trialPlanSub,
                    ),
                  ],
                ],
              ),
            ),
            if (chosen)
              Icon(
                Icons.check_circle_outline,
                size: 28.h,
                color: onGradient ? appTheme.onPrimary : appTheme.soothifyBlue,
              ),
          ],
        ),
      ),
    );
  }
}

class _DueToday extends StatelessWidget {
  const _DueToday({required this.due, required this.renews});

  final String due;
  final String renews;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Due today $due', style: CustomTextStyles.trialDue),
        Flexible(
          child: Text(
            renews,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: CustomTextStyles.trialRenews,
          ),
        ),
      ],
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check, size: 14.h, color: appTheme.soothifyBlue),
        SizedBox(width: 8.h),
        Expanded(
          child: Text(label, style: CustomTextStyles.trialBenefit),
        ),
      ],
    );
  }
}
