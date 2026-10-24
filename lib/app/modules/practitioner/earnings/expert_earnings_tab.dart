import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/skeleton.dart';
import '../../../data/models/expert_earnings.dart';
import '../dashboard/controller/expert_dashboard_controller.dart';
import '../widgets/expert_money.dart';

/// Earnings — Figma "Earning screen" (`3905:32063`).
///
/// Rebuilt from the frame rather than approximated. The screen is four cards,
/// not a flat column:
///
///   * a 342x183 brand-gradient card at 125 holding the balance and the
///     Withdraw button, with the service-charge note inside it;
///   * two 167x118 white tiles at 318 — this week and total earned;
///   * a 342x135 white card at 460 carrying the next payout date, a rule,
///     the payout method and a 27 round edit button;
///   * "Recent payouts" at 615, then 343x92 white cards at a 100 pitch.
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
                // No back chevron: Earnings is one of the bar's four tabs,
                // and there is nothing behind it to go back to.
                Text('Earnings',
                    textAlign: TextAlign.center,
                    style: CustomTextStyles.appBarTitle),
                SizedBox(height: 32.v),
                _BalanceCard(earnings: earnings),
                SizedBox(height: 10.v),
                _Summary(earnings: earnings),
                SizedBox(height: 24.v),
                _PayoutDetails(earnings: earnings),
                SizedBox(height: 24.v),
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
                SizedBox(height: 16.v),
                // The cards above degrade to em dashes and zeroes while the
                // figures arrive, so they keep their shape on their own.
                // This list has nothing to hold it open.
                if (earnings == null && controller.isLoading.value)
                  const SkeletonShimmer(
                    child: Column(
                      children: [
                        Skeleton(width: 343, height: 92),
                        SizedBox(height: 8),
                        Skeleton(width: 343, height: 92),
                        SizedBox(height: 8),
                        Skeleton(width: 343, height: 92),
                      ],
                    ),
                  )
                else
                  for (final payout
                      in earnings?.payouts ?? const <Payout>[]) ...[
                    PayoutCard(payout: payout),
                    SizedBox(height: 8.v),
                  ],
              ],
            );
          }),
        ),
      ),
    );
  }
}

/// The balance, the Withdraw button and the service-charge note, all inside
/// the one brand-gradient card the frame draws.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.earnings});

  final ExpertEarnings? earnings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.h, 24.v, 16.h, 24.v),
      decoration: BoxDecoration(
        gradient: appTheme.moodCardGradient,
        borderRadius: BorderRadius.circular(8.h),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // The wallet and the figure sit together at the card's left edge —
          // the frame ranges both left and only the note beneath is centred.
          Row(
            children: [
              Container(
                width: 34.h,
                height: 34.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appTheme.onPrimary.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: CustomImageView(
                  imagePath: ImageConstant.icWallet,
                  height: 19.h,
                  width: 19.h,
                  color: appTheme.onPrimary,
                ),
              ),
              SizedBox(width: 17.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available Earnings',
                        style: CustomTextStyles.expertBalanceCaption
                            .copyWith(color: appTheme.onPrimary)),
                    SizedBox(height: 4.v),
                    Text(money(earnings?.available ?? 0),
                        style: CustomTextStyles.expertBalanceAmount
                            .copyWith(color: appTheme.onPrimary)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.v),
          // White on the gradient, not the app's blue fill: on this card the
          // action has to read against the brand, not disappear into it.
          SizedBox(
            width: double.infinity,
            child: InkWell(
              // With no account on file the money has nowhere to land, so
              // the first withdrawal goes through the payout-method chooser.
              onTap: () => Get.toNamed(
                Get.find<ExpertDashboardController>().destinations.isEmpty
                    ? AppRoutes.expertPayoutMethod
                    : AppRoutes.expertWithdraw,
              ),
              borderRadius: BorderRadius.circular(8.h),
              child: Container(
                height: 52.v,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appTheme.onPrimary,
                  borderRadius: BorderRadius.circular(8.h),
                ),
                child: Text('Withdraw',
                    style: CustomTextStyles.subscribeLabel
                        .copyWith(color: appTheme.soothifyBlue)),
              ),
            ),
          ),
          SizedBox(height: 12.v),
          Text('10% bank service charges applies.',
              style: CustomTextStyles.expertBalanceCaption
                  .copyWith(color: appTheme.onPrimary)),
        ],
      ),
    );
  }
}

/// The next payout date and the method, in one card with a rule between and
/// a round edit button at its right.
class _PayoutDetails extends StatelessWidget {
  const _PayoutDetails({required this.earnings});

  final ExpertEarnings? earnings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(17.h, 17.v, 17.h, 17.v),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Column(
        children: [
          _DetailRow(
            label: 'Next automatic payout',
            value: switch (earnings) {
              null => '—',
              final e => payoutDay(e.nextPayout),
            },
          ),
          SizedBox(height: 20.v),
          Divider(height: 1.v, color: appTheme.cardRim),
          SizedBox(height: 20.v),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text('Payout method',
                        style: CustomTextStyles.expertRowLabel),
                    SizedBox(width: 20.h),
                    Flexible(
                      // The account on file, not the frame's placeholder:
                      // its "Bank ****1234" and its saved card's
                      // "0234 5678 890" never agreed with each other.
                      child: Obx(() {
                        final saved =
                            Get.find<ExpertDashboardController>().destinations;
                        return Text(
                          saved.isEmpty ? 'Not set' : saved.first.masked,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CustomTextStyles.expertRowLabel,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => Get.toNamed(AppRoutes.expertPayoutMethod),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 27.h,
                  height: 27.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: appTheme.statusIdleFill,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit_outlined,
                      size: 15.h, color: appTheme.textPrimary),
                ),
              ),
            ],
          ),
        ],
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
        SizedBox(width: 8.h),
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
    // A card of its own, 167x118 in the frame, not a bare column. No fixed
    // height: the three lines plus padding come to a touch over 118 once the
    // bundled face is used, and a hard height just overflows.
    return Container(
      padding: EdgeInsets.fromLTRB(17.h, 22.v, 17.h, 22.v),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
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
      ),
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

/// One payout, as the frame draws it: a 343x92 white card, the label over
/// its date on the left and the amount at the right.
///
/// Public because the "Recent payouts" screen lists the same card.
class PayoutCard extends StatelessWidget {
  const PayoutCard({super.key, required this.payout});

  final Payout payout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92.v,
      padding: EdgeInsets.symmetric(horizontal: 14.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
