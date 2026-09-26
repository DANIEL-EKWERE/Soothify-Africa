import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/expert_earnings.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../dashboard/controller/expert_dashboard_controller.dart';
import '../widgets/expert_money.dart';

/// Earnings — Figma "Earning screen" (`259:59366`).
///
/// Measured: the title at 70, the balance block from 149 with "Withdraw" at
/// 224 and its footnote at 268, a two-up summary at 343, the payout rows at
/// 477 and 557, "Recent payouts" at 615 with See All, then payout lines from
/// 673 at a 100 pitch.
///
/// The frame prints the balances in naira and the payout rows in dollars.
/// Naira throughout — see [ExpertEarnings.currencyNote].
class ExpertEarningsTab extends GetView<ExpertDashboardController> {
  const ExpertEarningsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: Obx(() {
            final earnings = controller.earnings.value;
            return ListView(
              padding: EdgeInsets.fromLTRB(24.h, 33.v, 24.h, 32.v),
              children: [
                Center(
                  child: Text('Earnings', style: CustomTextStyles.appBarTitle),
                ),
                SizedBox(height: 46.v),
                Center(
                  child: Column(
                    children: [
                      Text('Available Earnings',
                          style: CustomTextStyles.expertBalanceCaption),
                      SizedBox(height: 4.v),
                      Text(money(earnings?.available ?? 0),
                          style: CustomTextStyles.expertBalanceAmount),
                    ],
                  ),
                ),
                SizedBox(height: 26.v),
                CustomElevatedButton(
                  text: 'Withdraw',
                  onPressed: () => Get.toNamed(AppRoutes.expertWithdraw),
                ),
                SizedBox(height: 15.v),
                Center(
                  child: Text('10% bank service charges applies.',
                      style: CustomTextStyles.expertBalanceCaption),
                ),
                SizedBox(height: 43.v),
                _Summary(earnings: earnings),
                SizedBox(height: 50.v),
                _DetailRow(
                  label: 'Next automatic payout',
                  value: earnings == null
                      ? '—'
                      : payoutDay(earnings.nextPayout),
                ),
                SizedBox(height: 39.v),
                InkWell(
                  onTap: () => Get.toNamed(AppRoutes.expertPayoutMethod),
                  child: _DetailRow(
                    label: 'Payout method',
                    value: earnings?.payoutMethod ?? '—',
                  ),
                ),
                SizedBox(height: 37.v),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent payouts',
                        style: CustomTextStyles.expertSection),
                    InkWell(
                      onTap: () => Get.toNamed(AppRoutes.expertPayouts),
                      child: Text('See All',
                          style: CustomTextStyles.expertSeeAll),
                    ),
                  ],
                ),
                SizedBox(height: 37.v),
                for (final payout in earnings?.payouts ?? const <Payout>[])
                  _PayoutRow(payout: payout),
              ],
            );
          }),
        ),
      ),
    );
  }
}

/// "This week" and "Total earned", side by side with their session counts.
class _Summary extends StatelessWidget {
  const _Summary({required this.earnings});

  final ExpertEarnings? earnings;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _SummaryCell(
            caption: 'This week',
            amount: earnings?.thisWeek ?? 0,
            sessions: earnings?.thisWeekSessions ?? 0,
          ),
        ),
        Expanded(
          child: _SummaryCell(
            caption: 'Total earned',
            amount: earnings?.totalEarned ?? 0,
            sessions: earnings?.totalSessions ?? 0,
          ),
        ),
      ],
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.caption,
    required this.amount,
    required this.sessions,
  });

  final String caption;
  final int amount;
  final int sessions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(caption, style: CustomTextStyles.expertBalanceCaption),
        SizedBox(height: 4.v),
        Text(money(amount), style: CustomTextStyles.expertBalanceAmount),
        SizedBox(height: 4.v),
        Text(
          '$sessions ${sessions == 1 ? 'session' : 'sessions'}',
          style: CustomTextStyles.expertBalanceCaption,
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: CustomTextStyles.expertRowLabel),
        Text(value, style: CustomTextStyles.expertRowLabel),
      ],
    );
  }
}

class _PayoutRow extends StatelessWidget {
  const _PayoutRow({required this.payout});

  final Payout payout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 37.v),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payout.label, style: CustomTextStyles.expertRowLabel),
                SizedBox(height: 8.v),
                Text(payoutDay(payout.paidOn),
                    style: CustomTextStyles.expertPayoutDate),
              ],
            ),
          ),
          Text(money(payout.amount),
              style: CustomTextStyles.expertPayoutAmount),
        ],
      ),
    );
  }
}
