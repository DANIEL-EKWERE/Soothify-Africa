import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/passport_tier.dart';
import '../../../widgets/soothify_word.dart';
import 'controller/passport_controller.dart';

/// Choosing a Passport tier — Figma "Soothify Passport tier selection"
/// (`4958:26661`).
///
/// Measured from the frame: the page on `#F5FBFF`, the title row at 57,
/// "Find Your Rhythm" at 117 and its line at 149, then three 342x399 cards
/// from 221 at a 415 pitch. Inside a card: the name and its outlined level
/// pill at 24, the price at 62, who it is for at 105, a divider at 169, the
/// inclusions from 190, and a 294x52 action at 323.
///
/// The middle card is filled `#0A399A` with its text reversed. That is the
/// frame's emphasis, not a selection — tapping any card's button starts its
/// own checkout.
class PassportTiersScreen extends GetView<PassportController> {
  const PassportTiersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.passportPage,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10.v),
            _Header(onBack: Get.back),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 16.v, 24.h, 32.v),
                children: [
                  Text('passport.findRhythm'.tr, style: CustomTextStyles.tierName),
                  SizedBox(height: 8.v),
                  Text(
                    'passport.chooseBody'.tr,
                    style: CustomTextStyles.passportFor,
                  ),
                  SizedBox(height: 24.v),
                  for (final tier in controller.tiers) ...[
                    _TierCard(tier: tier),
                    SizedBox(height: 16.v),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.v,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 24.h),
              child: InkWell(
                onTap: onBack,
                customBorder: const CircleBorder(),
                child: CustomImageView(
                  imagePath: ImageConstant.icChevronLeft,
                  height: 24.h,
                  width: 24.h,
                  color: appTheme.textPrimary,
                ),
              ),
            ),
          ),
          SoothifyText('Soothify Passport', style: CustomTextStyles.appBarTitle),
        ],
      ),
    );
  }
}

/// One tier, as the frame draws it.
class _TierCard extends StatelessWidget {
  const _TierCard({required this.tier});

  final PassportTier tier;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PassportController>();
    final dark = tier.emphasised;
    // On the filled card every mark reverses — the text, the pill's ring,
    // the divider and the button, which swaps its fill for its label.
    final ink = dark ? appTheme.onPrimary : appTheme.textPrimary;
    return Container(
      padding: EdgeInsets.all(24.h),
      decoration: BoxDecoration(
        color: dark ? appTheme.brandInk : appTheme.surface,
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(tier.name,
                    style: CustomTextStyles.tierName.copyWith(color: ink)),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.h, vertical: 4.v),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.h),
                  border: Border.all(
                    color: dark ? appTheme.onPrimary : appTheme.passportRim,
                  ),
                ),
                child: Text(tier.level,
                    style:
                        CustomTextStyles.passportLevel.copyWith(color: ink)),
              ),
            ],
          ),
          SizedBox(height: 12.v),
          Text(tier.priceLabel,
              style: CustomTextStyles.passportPrice.copyWith(color: ink)),
          SizedBox(height: 12.v),
          Text(tier.practitioner,
              style: CustomTextStyles.passportFor.copyWith(color: ink)),
          SizedBox(height: 20.v),
          Divider(
            height: 1.v,
            thickness: 1,
            color: dark
                ? appTheme.onPrimary.withValues(alpha: 0.25)
                : appTheme.passportRim,
          ),
          SizedBox(height: 20.v),
          Text(tier.allowance,
              style: CustomTextStyles.passportAllowance.copyWith(color: ink)),
          SizedBox(height: 12.v),
          Text(tier.reformerLimit,
              style: CustomTextStyles.passportLimit.copyWith(color: ink)),
          SizedBox(height: 12.v),
          Text(tier.remainder,
              style:
                  CustomTextStyles.passportRemainder.copyWith(color: ink)),
          SizedBox(height: 20.v),
          Obx(
            () => InkWell(
              onTap: controller.busy.value
                  ? null
                  : () => controller.choose(tier),
              borderRadius: BorderRadius.circular(8.h),
              child: Container(
                height: 52.v,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: dark ? appTheme.onPrimary : appTheme.passportAction,
                  borderRadius: BorderRadius.circular(8.h),
                ),
                child: controller.busy.value &&
                        controller.chosen.value?.key == tier.key
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.h,
                          color: dark
                              ? appTheme.brandInk
                              : appTheme.onPrimary,
                        ),
                      )
                    : Text(
                        tier.action,
                        style: CustomTextStyles.passportAction.copyWith(
                          color:
                              dark ? appTheme.brandInk : appTheme.onPrimary,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
