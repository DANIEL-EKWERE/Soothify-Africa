import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/subscription_offer.dart';
import '../../../widgets/custom_ghost_button.dart';
import 'controller/subscription_offer_controller.dart';

/// The subscription pop-up — Figma `259:59011` (a 7-day trial) and
/// `259:58598` (a discounted year).
///
/// One screen for both: they share the blurb, the Free-vs-Premium table and
/// the footer, and differ in their title, their action, and whether a billing
/// period is picked.
///
/// Measured from `259:59011`: "Restore purchase" at 74.5, the title at 129,
/// the blurb at 171, the period cards 350 wide at 229 (119 tall) and 356 (70),
/// the table header at 442 with rows from 483, the action at 726 and the
/// footer at 798. Columns sit at 23, 253 and 307.
class SubscriptionOfferScreen extends GetView<SubscriptionOfferController> {
  const SubscriptionOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final offer = controller.offer;
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 26.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 23.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: Get.back,
                    child: Icon(Icons.close,
                        size: 22.h, color: appTheme.textPrimary),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: controller.restore,
                    child: Text('Restore purchase',
                        style: CustomTextStyles.restorePurchase),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(23.h, 33.v, 23.h, 24.v),
                children: [
                  _Title(offer: offer),
                  SizedBox(height: 16.v),
                  Text(
                    offer.blurb,
                    textAlign: TextAlign.center,
                    style: CustomTextStyles.offerBlurb,
                  ),
                  if (offer.choosePeriod) ...[
                    SizedBox(height: 16.v),
                    const _PeriodCards(),
                  ],
                  SizedBox(height: 32.v),
                  const _Comparison(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(23.h, 0, 23.h, 20.v),
              child: Column(
                children: [
                  // The frame draws this as the ghost button, not the filled
                  // one: white inside a #2F6FED outline with a blue label.
                  CustomGhostButton(
                    text: offer.action,
                    color: appTheme.soothifyBlue,
                    textStyle: CustomTextStyles.offerAction,
                    onPressed: controller.subscribe,
                  ),
                  SizedBox(height: 20.v),
                  InkWell(
                    onTap: controller.learnMore,
                    child: Text(offer.footer,
                        textAlign: TextAlign.center,
                        style: CustomTextStyles.offerBlurb),
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

/// The discounted offer strikes its old price through and prints the new one
/// beside it, inside the title.
class _Title extends StatelessWidget {
  const _Title({required this.offer});

  final SubscriptionOffer offer;

  @override
  Widget build(BuildContext context) {
    if (offer.wasPrice == null) {
      return Text(offer.title,
          textAlign: TextAlign.center, style: CustomTextStyles.offerTitle);
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${offer.title} '),
          TextSpan(
            text: offer.wasPrice,
            style: CustomTextStyles.offerTitle.copyWith(
              decoration: TextDecoration.lineThrough,
              color: appTheme.textSecondary,
            ),
          ),
          TextSpan(text: ' ${offer.nowPrice}'),
        ],
      ),
      textAlign: TextAlign.center,
      style: CustomTextStyles.offerTitle,
    );
  }
}

class _PeriodCards extends StatelessWidget {
  const _PeriodCards();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionOfferController>();
    return Obx(
      () => Column(
        children: [
          for (final period in OfferPeriod.values) ...[
            _PeriodCard(
              period: period,
              selected: controller.period.value == period,
            ),
            if (period != OfferPeriod.values.last) SizedBox(height: 8.v),
          ],
        ],
      ),
    );
  }
}

/// The chosen card is filled with the nav gradient and carries a tick; the
/// other is white inside a hairline. Both are drawn that way in the frame.
class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.period, required this.selected});

  final OfferPeriod period;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionOfferController>();
    final onFill = selected ? appTheme.onPrimary : appTheme.textPrimary;

    return GestureDetector(
      onTap: () => controller.choose(period),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.fromLTRB(24.h, 20.v, 24.h, 20.v),
        decoration: BoxDecoration(
          gradient: selected ? appTheme.navActiveGradient : null,
          color: selected ? null : appTheme.surface,
          borderRadius: BorderRadius.circular(16.h),
          border: selected ? null : Border.all(color: appTheme.textBlack),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (period.note != null) ...[
                    Text(period.note!,
                        style: CustomTextStyles.offerCardNote
                            .copyWith(color: onFill)),
                    SizedBox(height: 8.v),
                  ],
                  Text(
                    '${period.label} ${period.price}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        CustomTextStyles.offerCardTitle.copyWith(color: onFill),
                  ),
                  if (selected) ...[
                    SizedBox(height: 8.v),
                    Text(period.price,
                        style: CustomTextStyles.offerCardNote
                            .copyWith(color: onFill)),
                  ],
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check, size: 28.h, color: appTheme.onPrimary),
          ],
        ),
      ),
    );
  }
}

/// Feature / Free / Premium, five rows.
class _Comparison extends StatelessWidget {
  const _Comparison();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Feature', style: CustomTextStyles.offerColumn),
            ),
            SizedBox(
              width: 48.h,
              child: Text('Free',
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.offerColumn),
            ),
            SizedBox(
              width: 68.h,
              child: Text('Premium',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.offerColumn),
            ),
          ],
        ),
        SizedBox(height: 20.v),
        for (final row in SubscriptionOffer.comparison) ...[
          Row(
            children: [
              Expanded(
                child: Text(row.feature,
                    style: CustomTextStyles.offerFeature),
              ),
              SizedBox(
                width: 48.h,
                child: Icon(
                  row.free ? Icons.check : Icons.close,
                  size: 20.h,
                  color: row.free ? appTheme.success : appTheme.error,
                ),
              ),
              SizedBox(
                width: 68.h,
                child: Icon(Icons.check,
                    size: 20.h, color: appTheme.success),
              ),
            ],
          ),
          if (row != SubscriptionOffer.comparison.last)
            SizedBox(height: 22.v),
        ],
      ],
    );
  }
}
