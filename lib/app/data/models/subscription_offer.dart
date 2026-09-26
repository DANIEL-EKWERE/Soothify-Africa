/// One line of the Free-vs-Premium table — Figma "Subscription pop up"
/// (`259:59011`, `259:58598`).
class PlanComparisonRow {
  const PlanComparisonRow(this.feature, {required this.free});

  final String feature;

  /// Whether the free tier includes it. Premium includes every row — the
  /// frames tick all five in that column.
  final bool free;
}

/// Which pitch is being shown.
///
/// Two frames, the same table under two different offers: a 7-day trial
/// (`259:59011`, which also picks a billing period) and a 20%-off year
/// (`259:58598`, which does not).
enum SubscriptionOffer {
  trial(
    title: 'Try Soothify free for 7 days',
    action: 'Start free trial',
    choosePeriod: true,
  ),
  discountedYear(
    // The frame strikes 39,990 through and prints 23,990 beside it.
    title: 'Unlock a year of Soothify Core for',
    action: 'Claim 20% off',
    wasPrice: '₦39,990',
    nowPrice: '₦23,990',
  );

  const SubscriptionOffer({
    required this.title,
    required this.action,
    this.choosePeriod = false,
    this.wasPrice,
    this.nowPrice,
  });

  final String title;
  final String action;

  /// Whether the Annual/Monthly cards are shown above the table.
  final bool choosePeriod;

  final String? wasPrice;
  final String? nowPrice;

  /// Printed under the title on both frames, word for word.
  String get blurb =>
      'Get full, unlimited access to every guided session, expert guide, and '
      'library drop.';

  /// The footer, on both.
  String get footer => 'Not sure? Learn about our free year';

  /// The same five rows on both frames: the first is in the free tier, the
  /// rest are not.
  static const List<PlanComparisonRow> comparison = [
    PlanComparisonRow('Introductory exercises & basic articles', free: true),
    PlanComparisonRow('Full Pilates & Core media library', free: false),
    PlanComparisonRow(
      'Full Stretch & Restore & sleep support libraries',
      free: false,
    ),
    PlanComparisonRow(
      'Priority monthly group coaching & community Q&A',
      free: false,
    ),
    PlanComparisonRow(
      'Full in-app community access & shared circles',
      free: false,
    ),
  ];
}

/// The two billing periods the trial offer asks you to pick between.
///
/// Prices are preformatted placeholder strings, as everywhere else in this
/// file — the frame prints "₦15,000/monthly" on the annual card and
/// "₦15,000/One time access" on the monthly one, truncated to
/// "Monthly ₦15,000/One" by its own text box.
enum OfferPeriod {
  annual('Annual', '₦15,000/monthly', note: 'Best value - save 15% per year'),
  monthly('Monthly', '₦15,000/One time access');

  const OfferPeriod(this.label, this.price, {this.note});

  final String label;
  final String price;

  /// The line above the price on the highlighted card.
  final String? note;
}
