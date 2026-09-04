/// One of the three cards on the Plans screen.
///
/// Distinct from [SubscriptionPlan], which is the compact label-and-price row
/// in the Discovery upsell. This carries the marketing copy the Plans screen
/// prints, and knows whether the design gives it the filled emphasis
/// treatment.
class PlanTier {
  const PlanTier({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.emphasised = false,
  });

  final String id;
  final String name;

  /// Comma-separated selling points, printed as one paragraph in the design.
  final String description;

  final String price;

  /// The design fills one card with [PrimaryColors.brandInk] and reverses its
  /// text. That is emphasis, not selection — nothing on the frame is selected.
  final bool emphasised;

  factory PlanTier.fromJson(Map<String, dynamic> json) => PlanTier(
        id: '${json['id']}',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: json['price_display'] as String? ?? '',
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
