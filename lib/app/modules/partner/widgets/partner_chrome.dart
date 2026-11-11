import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/studio_partner.dart';
import '../../../widgets/soothify_word.dart';
import '../controller/partner_controller.dart';

/// "₦342,000" — grouped, as every figure in the portal is.
String partnerMoney(int naira) {
  final digits = naira.toString();
  final out = StringBuffer('₦');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return out.toString();
}

/// A class category's wash — the legend's colours, and the blocks on the
/// grid. Figma `416:26376`.
Color categoryWash(StudioClassCategory category) => switch (category) {
      StudioClassCategory.reformer => appTheme.categoryReformer,
      StudioClassCategory.mat => appTheme.categoryMat,
      StudioClassCategory.yoga => appTheme.categoryYoga,
    };

/// The header both frames share — the studio's mark, its name, the portal's
/// name beneath, and the bell with its unread dot.
class PartnerHeader extends StatelessWidget {
  const PartnerHeader({super.key, required this.studioName});

  final String studioName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.h, 22.v, 24.h, 0),
      child: Row(
        children: [
          Container(
            width: 44.h,
            height: 44.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: appTheme.soothifyBlue.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12.h),
            ),
            // The frame's sprout. Material stands in until it is exported.
            child: Icon(Icons.eco_outlined,
                size: 24.h, color: appTheme.soothifyBlue),
          ),
          SizedBox(width: 12.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(studioName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles.partnerStudio),
                SizedBox(height: 4.v),
                SoothifyText('partner.dashboard'.tr,
                    style: CustomTextStyles.partnerMeta),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40.h,
                height: 40.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appTheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.notifications_none_rounded,
                    size: 22.h, color: appTheme.textPrimary),
              ),
              Positioned(
                right: 6.h,
                top: 6.v,
                child: Container(
                  width: 6.h,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: appTheme.soothifyBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The two counts and the payout card, 342 wide across the top of both
/// frames.
class PartnerMetrics extends StatelessWidget {
  const PartnerMetrics({super.key, required this.overview});

  final StudioOverview? overview;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _Metric(
                icon: Icons.schedule_outlined,
                label: 'partner.pendingBookings'.tr,
                value: '${overview?.pending ?? 0}',
              ),
            ),
            SizedBox(width: 8.h),
            Expanded(
              child: _Metric(
                icon: Icons.check_circle_outline,
                label: 'partner.confirmedToday'.tr,
                value: '${overview?.confirmedToday ?? 0}',
              ),
            ),
          ],
        ),
        SizedBox(height: 8.v),
        _PayoutCard(overview: overview),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.v,
      padding: EdgeInsets.fromLTRB(14.h, 14.v, 14.h, 14.v),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.h, color: appTheme.partnerMuted),
              SizedBox(width: 6.h),
              Expanded(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles.partnerMeta),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: CustomTextStyles.partnerMetric),
        ],
      ),
    );
  }
}

/// "Monthly Payout Accrued" — the one filled card on the screen.
class _PayoutCard extends StatelessWidget {
  const _PayoutCard({required this.overview});

  final StudioOverview? overview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.h, 20.v, 16.h, 20.v),
      decoration: BoxDecoration(
        gradient: appTheme.moodCardGradient,
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Row(
        children: [
          Container(
            width: 36.h,
            height: 36.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: appTheme.onPrimary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: CustomImageView(
              imagePath: ImageConstant.icWallet,
              height: 20.h,
              width: 20.h,
              color: appTheme.onPrimary,
            ),
          ),
          SizedBox(width: 16.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('partner.monthlyPayout'.tr,
                    style: CustomTextStyles.partnerMeta
                        .copyWith(color: appTheme.onPrimary)),
                SizedBox(height: 4.v),
                Text(partnerMoney(overview?.payoutNaira ?? 0),
                    style: CustomTextStyles.partnerPayout),
                SizedBox(height: 4.v),
                Text(overview?.payoutPeriod ?? '',
                    style: CustomTextStyles.partnerMeta
                        .copyWith(color: appTheme.onPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

/// "Overview" / "Active Guest List" — one track, the chosen half in white.
class PartnerTabs extends StatelessWidget {
  const PartnerTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PartnerController>();
    return Obx(
      () => Container(
        height: 49.v,
        padding: EdgeInsets.all(4.h),
        decoration: BoxDecoration(
          color: appTheme.partnerTabTrack,
          borderRadius: BorderRadius.circular(12.h),
        ),
        child: Row(
          children: [
            for (final (tab, label) in const [
              (PartnerTab.overview, 'partner.overview'),
              (PartnerTab.guests, 'partner.guestList'),
            ])
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.show(tab),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: controller.tab.value == tab
                          ? appTheme.surface
                          : appTheme.transparent,
                      borderRadius: BorderRadius.circular(10.h),
                    ),
                    child: Text(
                      label.tr,
                      style: CustomTextStyles.partnerTab.copyWith(
                        color: controller.tab.value == tab
                            ? appTheme.soothifyBlue
                            : appTheme.partnerMuted,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A status pill — pending in amber, arrived in green.
class PartnerStatusPill extends StatelessWidget {
  const PartnerStatusPill({
    super.key,
    required this.label,
    required this.good,
  });

  final String label;
  final bool good;

  @override
  Widget build(BuildContext context) {
    final ink = good ? appTheme.partnerOkInk : appTheme.partnerWarnInk;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 5.v),
      decoration: BoxDecoration(
        color: good ? appTheme.partnerOkFill : appTheme.partnerWarnFill,
        borderRadius: BorderRadius.circular(8.h),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.h,
            height: 5.h,
            decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.h),
          Text(label,
              style: CustomTextStyles.partnerStatus.copyWith(color: ink)),
        ],
      ),
    );
  }
}
