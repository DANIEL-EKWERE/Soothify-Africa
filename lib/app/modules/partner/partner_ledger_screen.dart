import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';
import '../../data/models/studio_partner.dart';
import 'controller/partner_ledger_controller.dart';
import 'widgets/partner_chrome.dart';

/// "Financials & Settlement Hub" — Figma "4.2 · Studio payout ledger"
/// (`416:26282`).
///
/// Measured: the title row at 60, the heading at 128 with its line at 163,
/// the accrued balance card 342x112 at 199, two 166x103 metrics at 331, and
/// the table from 454 — its heading, a 342x52 month filter, the count, then
/// 342-wide rows. The newest row is 162 tall because it alone carries
/// "Dispute Check-In"; the rest are 120.
class PartnerLedgerScreen extends GetView<PartnerLedgerController> {
  const PartnerLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.passportPage,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.v),
            Row(
              children: [
                SizedBox(width: 24.h),
                InkWell(
                  onTap: Get.back,
                  customBorder: const CircleBorder(),
                  child: CustomImageView(
                    imagePath: ImageConstant.icChevronLeft,
                    height: 24.h,
                    width: 24.h,
                    color: appTheme.textPrimary,
                  ),
                ),
                Expanded(
                  child: Text('Studio payout ledger',
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.partnerCardTitle
                          .copyWith(fontSize: 16.fSize)),
                ),
                SizedBox(width: 48.h),
              ],
            ),
            Expanded(
              child: Obx(
                () => RefreshIndicator(
                  onRefresh: controller.load,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(24.h, 20.v, 24.h, 32.v),
                    children: [
                      Text('Financials & Settlement Hub',
                          style: CustomTextStyles.partnerSection
                              .copyWith(fontSize: 20.fSize)),
                      SizedBox(height: 8.v),
                      Text('Your verified check-ins, earnings and payouts.',
                          style: CustomTextStyles.partnerMeta),
                      SizedBox(height: 20.v),
                      _Accrued(ledger: controller.ledger.value),
                      SizedBox(height: 20.v),
                      _SettlementMetrics(ledger: controller.ledger.value),
                      SizedBox(height: 20.v),
                      _Table(controller: controller),
                      SizedBox(height: 20.v),
                      Text(
                        'Payouts are processed on the 1st and 15th. Dispute '
                        'a check-in within 48 hours.',
                        style: CustomTextStyles.partnerMeta,
                      ),
                    ],
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

/// The filled card: what is owed but not yet paid.
class _Accrued extends StatelessWidget {
  const _Accrued({required this.ledger});

  final StudioLedger? ledger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.h, 16.v, 16.h, 16.v),
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
                Text('Accrued Unpaid Balance',
                    style: CustomTextStyles.partnerStatus
                        .copyWith(color: appTheme.onPrimary)),
                SizedBox(height: 6.v),
                Text(partnerMoney(ledger?.accruedNaira ?? 0),
                    style: CustomTextStyles.partnerPayout
                        .copyWith(fontSize: 24.fSize)),
                SizedBox(height: 6.v),
                Text('Queued for your next settlement',
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

class _SettlementMetrics extends StatelessWidget {
  const _SettlementMetrics({required this.ledger});

  final StudioLedger? ledger;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Settlement(
            label: 'Next Disbursement',
            value: ledger == null
                ? '—'
                : DateFormat('dd MMM yyyy').format(ledger!.nextDisbursement),
            note: 'Every 1st & 15th',
          ),
        ),
        SizedBox(width: 10.h),
        Expanded(
          child: _Settlement(
            label: 'Lifetime Earnings',
            value: partnerMoney(ledger?.lifetimeNaira ?? 0),
            note: 'Total earned to date',
          ),
        ),
      ],
    );
  }
}

class _Settlement extends StatelessWidget {
  const _Settlement({
    required this.label,
    required this.value,
    required this.note,
  });

  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 103.v,
      padding: EdgeInsets.all(17.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: CustomTextStyles.partnerMeta),
          SizedBox(height: 6.v),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CustomTextStyles.partnerCardTitle
                  .copyWith(fontSize: 16.fSize)),
          const Spacer(),
          Text(note, style: CustomTextStyles.partnerMeta),
        ],
      ),
    );
  }
}

class _Table extends StatelessWidget {
  const _Table({required this.controller});

  final PartnerLedgerController controller;

  @override
  Widget build(BuildContext context) {
    final ledger = controller.ledger.value;
    final rows = ledger?.earnings ?? const <StudioEarning>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Earnings', style: CustomTextStyles.partnerSection),
        SizedBox(height: 12.v),
        Container(
          height: 52.v,
          padding: EdgeInsets.symmetric(horizontal: 17.h),
          decoration: BoxDecoration(
            color: appTheme.surface,
            borderRadius: BorderRadius.circular(10.h),
            border: Border.all(color: appTheme.cardRim),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(ledger?.period ?? '',
                    style: CustomTextStyles.partnerCardBody),
              ),
              Icon(Icons.event_note_outlined,
                  size: 18.h, color: appTheme.partnerMuted),
            ],
          ),
        ),
        SizedBox(height: 12.v),
        Text(
          'Showing the latest ${rows.length} of '
          '${ledger?.totalEarnings ?? rows.length} earnings',
          style: CustomTextStyles.partnerMeta,
        ),
        SizedBox(height: 12.v),
        for (final row in rows) ...[
          _EarningRow(earning: row, controller: controller),
          SizedBox(height: 12.v),
        ],
      ],
    );
  }
}

class _EarningRow extends StatelessWidget {
  const _EarningRow({required this.earning, required this.controller});

  final StudioEarning earning;
  final PartnerLedgerController controller;

  @override
  Widget build(BuildContext context) {
    final settled = earning.status == StudioEarningStatus.disbursed;
    return Container(
      padding: EdgeInsets.all(17.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(earning.guestName,
                        style: CustomTextStyles.partnerCardTitle),
                    SizedBox(height: 2.v),
                    Text('Class category · ${earning.category}',
                        style: CustomTextStyles.partnerMeta),
                  ],
                ),
              ),
              Text(DateFormat('dd MMM yyyy').format(earning.earnedOn),
                  style: CustomTextStyles.partnerMeta),
            ],
          ),
          SizedBox(height: 10.v),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Wholesale Payout Amount',
                        style: CustomTextStyles.partnerMeta),
                    SizedBox(height: 2.v),
                    Text(partnerMoney(earning.payoutNaira),
                        style: CustomTextStyles.partnerCardTitle
                            .copyWith(fontSize: 18.fSize)),
                  ],
                ),
              ),
              // Queued is the brand wash; disbursed is the settled green.
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.h, vertical: 5.v),
                decoration: BoxDecoration(
                  color: settled
                      ? appTheme.partnerOkFill
                      : appTheme.partnerQueuedFill,
                  borderRadius: BorderRadius.circular(8.h),
                ),
                child: Text(
                  earning.status.label,
                  style: CustomTextStyles.partnerStatus.copyWith(
                    fontSize: 10.fSize,
                    color: settled
                        ? appTheme.textPrimary
                        : appTheme.soothifyBlue,
                  ),
                ),
              ),
            ],
          ),
          if (earning.disputable &&
              earning.status != StudioEarningStatus.disputed) ...[
            SizedBox(height: 14.v),
            Obx(() {
              final busy = controller.busyId.value == earning.id;
              return InkWell(
                onTap: busy ? null : () => controller.dispute(earning),
                borderRadius: BorderRadius.circular(8.h),
                child: Container(
                  height: 34.v,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: appTheme.surface,
                    borderRadius: BorderRadius.circular(8.h),
                    border: Border.all(color: appTheme.soothifyBlue),
                  ),
                  child: busy
                      ? SizedBox(
                          height: 14.h,
                          width: 14.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.h,
                            color: appTheme.soothifyBlue,
                          ),
                        )
                      : Text('Dispute Check-In',
                          style: CustomTextStyles.partnerStatus.copyWith(
                            color: appTheme.soothifyBlue,
                          )),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
