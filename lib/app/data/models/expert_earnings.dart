/// One line on "Recent payouts" — Figma "Earning screen" (`259:59366`).
class Payout {
  const Payout({
    required this.id,
    required this.label,
    required this.amount,
    required this.paidOn,
  });

  final String id;

  /// "Weekly payout" on every row the frame draws.
  final String label;

  /// In naira. See [ExpertEarnings.currencyNote].
  final int amount;

  final DateTime paidOn;
}

/// What the Earnings screen shows — Figma `259:59366`.
class ExpertEarnings {
  const ExpertEarnings({
    required this.available,
    required this.thisWeek,
    required this.thisWeekSessions,
    required this.totalEarned,
    required this.totalSessions,
    required this.nextPayout,
    required this.payoutMethod,
    required this.payouts,
  });

  /// The balance above "Withdraw", and the figure the dashboard's card shows.
  final int available;

  final int thisWeek;
  final int thisWeekSessions;
  final int totalEarned;
  final int totalSessions;

  final DateTime nextPayout;

  /// "Bank ****1234".
  final String payoutMethod;

  final List<Payout> payouts;

  /// The frame is inconsistent with itself: the balances are in naira
  /// ("₦1240") and the payout rows in dollars ("$1,105"). The app is Nigerian
  /// and its booking prices are in naira, so naira wins throughout — and the
  /// figures are grouped, which the frame's own "₦1240" is not.
  static const String currencyNote =
      'Amounts are naira; the frame mixes ₦ and \$.';

  /// The frame's own numbers, with the dollar rows read as naira.
  static ExpertEarnings sample({DateTime Function()? now}) {
    final at = (now ?? DateTime.now)();
    // The frame prints "Fri, 26 Sep" for the next payout and "Fri, 19 Sep"
    // for every row behind it.
    final nextFriday = at.add(Duration(days: (5 - at.weekday + 7) % 7));
    return ExpertEarnings(
      available: 1240,
      thisWeek: 1240,
      thisWeekSessions: 3,
      totalEarned: 1240,
      totalSessions: 5,
      nextPayout: nextFriday,
      payoutMethod: 'Bank ****1234',
      payouts: [
        for (var i = 1; i <= 4; i++)
          Payout(
            id: '$i',
            label: 'Weekly payout',
            amount: 1105,
            paidOn: nextFriday.subtract(Duration(days: 7 * i)),
          ),
      ],
    );
  }
}
