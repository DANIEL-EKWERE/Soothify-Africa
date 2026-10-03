/// One of the three cards on the Plans screen.
///
/// Distinct from [SubscriptionPlan], which is the compact label-and-price row
/// in the Discovery upsell. This carries the marketing copy the Plans screen
/// prints, and knows whether the design gives it the filled emphasis
/// treatment.
/// What a card offers instead of, or as well as, a price.
enum PlanAction {
  /// The Passport card's "Join the Waitlist" — opens the waitlist sheet the
  /// Spaces flow already uses, since it is the same waitlist.
  waitlist('Join the Waitlist'),

  /// The Corporate card's "Speak with Corporate Team".
  corporate('Speak with Corporate Team');

  const PlanAction(this.label);

  final String label;
}

class PlanTier {
  const PlanTier({
    required this.id,
    required this.name,
    required this.description,
    this.price = '',
    this.priceSuffix = '',
    this.action,
    this.emphasised = false,
  });

  final String id;
  final String name;

  /// One paragraph of marketing copy, printed as the design writes it.
  final String description;

  /// The amount alone — "₦15,000". Empty on a card that sells no price, which
  /// is both of the other two.
  final String price;

  /// What follows the amount in grey at a smaller size: "/One time access".
  final String priceSuffix;

  /// The link under the copy, where the card has one instead of a price.
  final PlanAction? action;

  /// The design fills one card with [PrimaryColors.brandInk] and reverses its
  /// text. That is emphasis, not selection — nothing on the frame is
  /// selected, and the cards are not selectable.
  final bool emphasised;

  bool get hasPrice => price.isNotEmpty;

  factory PlanTier.fromJson(Map<String, dynamic> json) => PlanTier(
        id: '${json['id']}',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: json['price_display'] as String? ?? '',
        priceSuffix: json['price_suffix'] as String? ?? '',
        action: switch (json['action'] as String?) {
          'waitlist' => PlanAction.waitlist,
          'corporate' => PlanAction.corporate,
          _ => null,
        },
        emphasised: json['is_recommended'] as bool? ?? false,
      );
}

/// The billing period toggle at the top of Plans.
enum BillingPeriod {
  monthly('Monthly'),
  annual('Annual');

  const BillingPeriod(this.label);

  final String label;
}
