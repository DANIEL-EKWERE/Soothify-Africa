import 'package:intl/intl.dart';

/// A naira figure, grouped.
///
/// The client's booking screen adds the same sign for the same reason: the
/// frames print bare numbers, and an amount with no unit on a money screen is
/// a hazard. The Earnings frame is worse than bare — it mixes "₦1240" for the
/// balances with "$1,105" for the payout rows. The app is Nigerian and its
/// prices are in naira, so naira is used throughout.
String money(int naira) =>
    '₦${NumberFormat.decimalPattern('en').format(naira)}';

/// "25 sep, 2026" — the dashboard card's form.
String payoutDate(DateTime at) => DateFormat('d MMM, yyyy').format(at);

/// "Fri, 26 Sep" — the Earnings screen's form.
String payoutDay(DateTime at) => DateFormat('EEE, d MMM').format(at);
