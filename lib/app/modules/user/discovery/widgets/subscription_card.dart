import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/subscription_plan.dart';

/// The "Unlock every feature" block — Figma 135:3467.
///
/// Lives in its own file because the Plans tab carries the same card; it takes
/// its data and callbacks rather than reaching for a controller, so both can
/// use it.
class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    super.key,
    required this.plans,
    required this.selectedPlanId,
    required this.freeTrial,
    required this.onPlanSelected,
    required this.onFreeTrialChanged,
    required this.onSubscribe,
  });

  final List<SubscriptionPlan> plans;
  final String selectedPlanId;
  final bool freeTrial;
  final ValueChanged<String> onPlanSelected;
  final ValueChanged<bool> onFreeTrialChanged;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.h, 23.v, 24.h, 23.v),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(24.h),
        border: Border.all(color: appTheme.planCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Unlock every feature',
            textAlign: TextAlign.center,
            style: CustomTextStyles.appBarTitle,
          ),
          SizedBox(height: 23.v),
          _TrialRow(value: freeTrial, onChanged: onFreeTrialChanged),
          SizedBox(height: 23.v),
          for (final plan in plans) ...[
            _PlanRow(
              plan: plan,
              selected: plan.id == selectedPlanId,
              onTap: () => onPlanSelected(plan.id),
            ),
            SizedBox(height: 13.v),
          ],
          SizedBox(height: 28.v),
          _SubscribeButton(onTap: onSubscribe),
        ],
      ),
    );
  }
}

class _TrialRow extends StatelessWidget {
  const _TrialRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 47.v,
      padding: EdgeInsets.symmetric(horizontal: 17.h),
      decoration: BoxDecoration(
        color: appTheme.trialBanner,
        borderRadius: BorderRadius.circular(24.h),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Not sure yet? Enable free trial',
              style: CustomTextStyles.planLabel,
            ),
          ),
          // Cupertino's own switch, sized to the design's 39.5x24 track.
          Transform.scale(
            scale: 0.85,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: appTheme.soothifyBlue,
              inactiveTrackColor: appTheme.toggleTrack,
              // The design's knob is white in both states; Material's default
              // renders the off-state thumb dark, which reads as disabled.
              thumbColor: WidgetStatePropertyAll(appTheme.onPrimary),
              trackOutlineColor:
                  WidgetStatePropertyAll(appTheme.toggleTrack),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final SubscriptionPlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 40.v,
        padding: EdgeInsets.symmetric(horizontal: 13.h),
        decoration: BoxDecoration(
          color: selected ? appTheme.planSelectedFill : appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(
            color: selected ? appTheme.soothifyBlue : appTheme.planBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                plan.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStyles.planLabel,
              ),
            ),
            SizedBox(width: 8.h),
            Text(plan.price, style: CustomTextStyles.planLabel),
          ],
        ),
      ),
    );
  }
}

class _SubscribeButton extends StatelessWidget {
  const _SubscribeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 48.v,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: appTheme.actionFill,
          borderRadius: BorderRadius.circular(8.h),
        ),
        child: Text('Subscribe', style: CustomTextStyles.subscribeLabel),
      ),
    );
  }
}
