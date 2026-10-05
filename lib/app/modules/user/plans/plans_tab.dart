import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/plan_tier.dart';
import '../spaces/widgets/passport_sheet.dart';
import '../../../widgets/gradient_text.dart';
import 'controller/plans_tab_controller.dart';

/// Plans — redrawn by the designer on 2026-10-02, measured from the
/// screenshot they supplied rather than from the file (which still holds the
/// old "One-Off / Pro / Corporate" screen at 135:2444).
///
/// A back arrow and a centred title, a Monthly/Annual toggle, three cards and
/// the trial button. The frame's own bottom navigation is skipped; the shell
/// supplies it.
///
/// Measured below the status bar, at a 390 frame: title 22.5, toggle 81 (40
/// tall), first card 147, cards 22 apart, trial button 43 under the last one
/// and 52 tall. Content margin 24, card padding 25.
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
            padding: EdgeInsets.fromLTRB(24.h, 16.v, 24.h, 32.v),
            children: [
              const _Header(),
              SizedBox(height: 41.v),
              const _PeriodToggle(),
              SizedBox(height: 24.v),
              Obx(
                () => Column(
                  children: [
                    for (final tier in controller.tiers) ...[
                      _TierCard(tier: tier),
                      SizedBox(height: 17.v),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlansTabController>();
    return Row(
      children: [
        InkWell(
          onTap: controller.back,
          customBorder: const CircleBorder(),
          child: Icon(
            Icons.chevron_left,
            size: 24.h,
            color: appTheme.textPrimary,
          ),
        ),
        Expanded(
          child: Text(
            'Plans',
            textAlign: TextAlign.center,
            style: CustomTextStyles.appBarTitle,
          ),
        ),
        SizedBox(width: 24.h),
      ],
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
        height: 40.v,
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(100.h),
          border: Border.all(color: appTheme.periodToggleBorder),
        ),
        // 182 of the 342 content width goes to Monthly, as measured off the
        // screenshot at a y clear of the label — scanning through "Monthly"
        // itself cut the fill short and put the split at 119.
        child: Row(
          children: [
            Expanded(
              flex: 182,
              child: _PeriodSegment(
                period: BillingPeriod.monthly,
                selected: period == BillingPeriod.monthly,
                onTap: () => controller.selectPeriod(BillingPeriod.monthly),
              ),
            ),
            Expanded(
              flex: 160,
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
          gradient: selected ? appTheme.periodSelectedGradient : null,
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

/// One plan card.
///
/// At rest every card sits on the app's 4% hairline. Tapping one rings it in
/// its own accent — the brand blue on a white card, the brand orange on the
/// filled one, where blue would disappear into its own fill. Each ends in
/// its own button: the trial, the waitlist sheet, or the corporate form.
class _TierCard extends StatelessWidget {
  const _TierCard({required this.tier});

  final PlanTier tier;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlansTabController>();
    final onDark = tier.emphasised;
    // onPrimary, not a themed text colour: the emphasis fill stays the same
    // deep blue in dark mode, so its text must stay white with it.
    final foreground = onDark ? appTheme.onPrimary : appTheme.textPrimary;

    // Its own Obx. The card is built from the list's Obx but renders outside
    // it, so reading `chosen` there would never register.
    return Obx(
      () => GestureDetector(
        onTap: () => controller.choose(tier.id),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.fromLTRB(25.h, 34.v, 25.h, 34.v),
          decoration: BoxDecoration(
            color: onDark ? appTheme.planEmphasisFill : appTheme.surface,
            borderRadius: BorderRadius.circular(16.h),
            border: Border.all(
              color: switch ((controller.chosen.value == tier.id, onDark)) {
                (false, _) => appTheme.cardRim,
                (true, true) => appTheme.planEmphasisOutline,
                (true, false) => appTheme.actionFill,
              },
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
              SizedBox(height: 28.v),
              if (tier.hasPrice) ...[
                _Price(tier: tier),
                SizedBox(height: 24.v),
              ],
              if (tier.action != null)
                _TierButton(
                  action: tier.action!,
                  onDark: onDark,
                  onTap: () => switch (tier.action!) {
                    PlanAction.trial => controller.startTrial(),
                    PlanAction.waitlist => PassportSheet.show(context),
                    PlanAction.corporate => controller.openCorporateForm(),
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "₦15,000/One time access" — the amount in the brand gradient, the terms
/// after it in grey at two thirds the size.
class _Price extends StatelessWidget {
  const _Price({required this.tier});

  final PlanTier tier;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        GradientText(
          tier.price,
          gradient: appTheme.navActiveGradient,
          style: CustomTextStyles.tierPrice,
        ),
        Flexible(
          child: Text(
            tier.priceSuffix,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CustomTextStyles.tierPriceTerms,
          ),
        ),
      ],
    );
  }
}

/// The card's own button.
///
/// The outlined trial button that used to sit under the whole list, now one
/// per card: white with a blue ring on the white cards, and transparent with
/// a white ring on the filled one, where a blue ring would be unreadable.
class _TierButton extends StatelessWidget {
  const _TierButton({
    required this.action,
    required this.onDark,
    required this.onTap,
  });

  final PlanAction action;
  final bool onDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colour = onDark ? appTheme.onPrimary : appTheme.soothifyBlue;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 52.v,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12.h),
        decoration: BoxDecoration(
          color: onDark ? Colors.transparent : appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(color: colour),
        ),
        child: Text(
          action.label,
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: CustomTextStyles.trialButtonLabel.copyWith(color: colour),
        ),
      ),
    );
  }
}
