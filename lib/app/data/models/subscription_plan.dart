/// One row in the "Unlock every feature" card.
///
/// The design prices all three identically (NGN 5,000 / day), which is
/// placeholder copy rather than a pricing decision — the real figures come
/// from the backend, so [price] is a preformatted string here and not a
/// number this app does currency maths on.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.label,
    required this.price,
  });

  final String id;
  final String label;
  final String price;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      SubscriptionPlan(
        id: '${json['id']}',
        label: json['label'] as String? ?? '',
        price: json['price_display'] as String? ?? '',
      );
}
