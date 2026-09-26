import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/expert_earnings.dart';
import '../widgets/expert_header.dart';
import '../widgets/expert_money.dart';
import 'controller/payout_controller.dart';

/// The full payout history — Figma "Recent payouts" (`259:59782`).
///
/// Measured: the title at 70, rows from 138 at a 100 pitch — the label at the
/// top, the date 29 beneath it, and the figure right-aligned between them.
///
/// The frame prints "$1,105" here and "₦1240" on the screen that links to it.
/// Naira, as everywhere else — see [ExpertEarnings.currencyNote].
class ExpertPayoutsScreen extends GetView<PayoutController> {
  const ExpertPayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 33.v),
            const ExpertHeader(title: 'Recent payouts'),
            Expanded(
              child: Obx(() {
                final payouts = controller.payouts;
                if (payouts.isEmpty) {
                  return ListView(
                    padding: EdgeInsets.fromLTRB(24.h, 46.v, 24.h, 32.v),
                    children: [
                      Text('No payouts yet.',
                          style: CustomTextStyles.expertCardMeta),
                    ],
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(24.h, 46.v, 24.h, 32.v),
                  itemCount: payouts.length,
                  separatorBuilder: (_, _) => SizedBox(height: 37.v),
                  itemBuilder: (context, i) => _PayoutRow(payout: payouts[i]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayoutRow extends StatelessWidget {
  const _PayoutRow({required this.payout});

  final Payout payout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.h),
      child: Row(
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
