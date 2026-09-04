import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/plan_tier.dart';
import '../../../widgets/gradient_text.dart';
import 'controller/plans_tab_controller.dart';

/// Plans — Figma "Plans" (135:2444).
///
/// A Monthly/Annual toggle over three plan cards and a continue button. The
/// frame's own bottom navigation at y=1210 is skipped; the shell supplies it.
///
/// The button's label in the file is the component's placeholder, "Large
/// button". "Continue" is used here because the frame gives no real label —
/// worth confirming against the designer.
class PlansTab extends GetView<PlansTabController> {
  const PlansTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: EdgeInsets.fromLTRB(24.h, 21.v, 24.h, 32.v),
            children: [
              Text(
                'Plans',
                textAlign: TextAlign.center,
                style: CustomTextStyles.sectionTitle.copyWith(
                  fontWeight: FontWeight.w700,
                  fontVariations: const [FontVariation('wght', 700)],
                ),
              ),
              SizedBox(height: 35.v),
              const _PeriodToggle(),
              SizedBox(height: 24.v),
              Obx(() => Column(
                    children: [
                      for (final tier in controller.tiers) ...[
                        _TierCard(tier: tier),
                        SizedBox(height: 16.v),
                      ],
                    ],
                  )),
              SizedBox(height: 24.v),
              const _ContinueButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlansTabController>();
    return Obx(() {
      final period = controller.period.value;
      return Container(
        height: 73.v,
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(100.h),
          border: Border.all(color: appTheme.periodToggleBorder),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 187,
              child: _PeriodSegment(
                period: BillingPeriod.monthly,
                selected: period == BillingPeriod.monthly,
                onTap: () => controller.selectPeriod(BillingPeriod.monthly),
              ),
            ),
            SizedBox(width: 16.h),
            Expanded(
              flex: 115,
              child: _PeriodSegment(
                period: BillingPeriod.annual,
                selected: period == BillingPeriod.annual,
                onTap: () => controller.selectPeriod(BillingPeriod.annual),
                // Only the Annual segment carries the saving line.
                saving: 'Save up to  #10,000',
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _PeriodSegment extends StatelessWidget {
  const _PeriodSegment({
    required this.period,
    required this.selected,
    required this.onTap,
    this.saving,
  });

  final BillingPeriod period;
  final bool selected;
  final VoidCallback onTap;
  final String? saving;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100.h),
      child: Container(
        decoration: BoxDecoration(
          // The selected segment takes the auth header's gradient, folded with
          // the design's 20% black overlay.
          gradient: selected ? appTheme.authHeaderGradient : null,
          borderRadius: BorderRadius.circular(100.h),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              period.label,
              textAlign: TextAlign.center,
              style: CustomTextStyles.periodLabel.copyWith(
                color: selected ? appTheme.onPrimary : appTheme.textPrimary,
              ),
            ),
            if (saving != null && !selected)
              GradientText(
                saving!,
                gradient: appTheme.navActiveGradient,
                textAlign: TextAlign.center,
                style: CustomTextStyles.periodSaving,
              ),
          ],
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({required this.tier});

  final PlanTier tier;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlansTabController>();
    return Obx(() {
      final selected = controller.selectedTierId.value == tier.id;
      // Emphasis is the design's fixed treatment for the Pro card; selection
      // is the user's, and shows as a heavier outline so the two never read as
      // the same thing.
      final onDark = tier.emphasised;
      // onPrimary, not a themed text colour: the emphasis fill stays the same
      // deep blue in dark mode, so its text must stay white with it.
      final foreground = onDark ? appTheme.onPrimary : appTheme.textPrimary;

      return InkWell(
        onTap: () => controller.selectTier(tier.id),
        borderRadius: BorderRadius.circular(16.h),
        child: Container(
          padding: EdgeInsets.fromLTRB(25.h, 39.v, 23.h, 39.v),
          decoration: BoxDecoration(
            color: onDark ? appTheme.planEmphasisFill : appTheme.surface,
            borderRadius: BorderRadius.circular(16.h),
            border: onDark
                ? null
                : Border.all(
                    color: appTheme.actionFill,
                    width: selected ? 2 : 1,
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tier.name,
                style: CustomTextStyles.tierName.copyWith(color: foreground),
              ),
              SizedBox(height: 16.v),
              Text(
                tier.description,
                style: CustomTextStyles.tierBody.copyWith(color: foreground),
              ),
              SizedBox(height: 24.v),
              Text(
                tier.price,
                style: CustomTextStyles.tierPrice.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlansTabController>();
    return Obx(() {
      final enabled = controller.canContinue;
      return InkWell(
        onTap: enabled ? controller.proceed : null,
        borderRadius: BorderRadius.circular(8.h),
        child: Container(
          height: 52.v,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? appTheme.actionFill : appTheme.actionFillDisabled,
            borderRadius: BorderRadius.circular(8.h),
          ),
          child: Text(
            'Continue',
            style: CustomTextStyles.subscribeLabel.copyWith(fontSize: 18.fSize),
          ),
        ),
      );
    });
  }
}
