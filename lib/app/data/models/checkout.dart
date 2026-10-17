/// What the server hands back when a payment is started.
///
/// The app opens [checkoutUrl] and waits; nothing is paid for until the
/// provider's webhook reaches the server, which is why [reference] exists —
/// it is what the app polls to find out.
class Checkout {
  const Checkout({
    required this.reference,
    required this.checkoutUrl,
    required this.amountNaira,
    this.checkoutId = '',
    this.trialDays = 0,
    this.dueTodayNaira = 0,
    this.trialStarted = false,
    this.cardCheckNaira = 0,
  });

  final String reference;
  final String checkoutUrl;
  final int amountNaira;
  final String checkoutId;

  /// Zero when this is not a trial. A trial charges nothing today, which is
  /// what the pop-up's "Due today ₦0.00" is telling the user.
  final int trialDays;
  final int dueTodayNaira;

  /// The free week has already begun, and there is nothing to open.
  ///
  /// While memberships are sold a period at a time, the server grants the
  /// trial on the spot: no card is saved, because there would be no way to
  /// charge it afterwards. The screen should go straight in rather than
  /// waiting on a browser that is never going to open.
  final bool trialStarted;

  /// What is taken to prove the card, and given straight back. Zero when no
  /// card was asked for. The checkout that opens is for this amount, not
  /// for the price of the plan, so the screen must not say otherwise.
  final int cardCheckNaira;

  factory Checkout.fromJson(Map<String, dynamic> json) => Checkout(
        reference: json['reference'] as String? ?? '',
        checkoutUrl: json['checkout_url'] as String? ?? '',
        amountNaira: json['amount_naira'] as int? ?? 0,
        checkoutId: json['checkout_id'] as String? ?? '',
        trialDays: json['trial_days'] as int? ?? 0,
        dueTodayNaira: json['due_today_naira'] as int? ?? 0,
        trialStarted: json['trial_started'] as bool? ?? false,
        cardCheckNaira: json['card_check_naira'] as int? ?? 0,
      );
}

/// Where a membership stands, from `/billing/membership/`.
class MembershipStatus {
  const MembershipStatus({
    required this.state,
    this.planKey = '',
    this.planName = '',
    this.cadence = 'annual',
    this.trialEndsAt,
    this.renewsAt,
    this.card = '',
    this.nextChargeNaira = 0,
    this.isActive = false,
    this.autoRenew = true,
    this.trialAvailable = true,
    this.trialRequiresCard = false,
    this.cardCheckNaira = 0,
  });

  /// 'inactive', 'trial', 'active', 'past_due' or 'cancelled'.
  final String state;
  final String planKey;
  final String planName;
  final String cadence;
  final DateTime? trialEndsAt;
  final DateTime? renewsAt;

  /// "Mastercard ending in 1234", or empty before a card is saved.
  final String card;
  final int nextChargeNaira;

  /// Whether paid content may be played. A trial counts.
  final bool isActive;

  /// Whether [renewsAt] is a renewal or an ending.
  ///
  /// False while memberships are sold one period at a time: nothing is
  /// charged automatically, and the member comes back and pays. The screens
  /// must say which, or somebody loses access believing they were covered.
  final bool autoRenew;

  /// Whether this account can still take the free week. One each.
  final bool trialAvailable;

  /// Whether the free week asks for a card before it starts, and what is
  /// taken to prove it -- refunded, but it does leave their account, so
  /// the offer has to say so before anybody taps.
  final bool trialRequiresCard;
  final int cardCheckNaira;

  bool get isOnTrial => state == 'trial';

  static const MembershipStatus none = MembershipStatus(state: 'inactive');

  factory MembershipStatus.fromJson(Map<String, dynamic> json) =>
      MembershipStatus(
        state: json['state'] as String? ?? 'inactive',
        planKey: json['plan_key'] as String? ?? '',
        planName: json['plan_name'] as String? ?? '',
        cadence: json['cadence'] as String? ?? 'annual',
        trialEndsAt: DateTime.tryParse('${json['trial_ends_at']}')?.toLocal(),
        renewsAt: DateTime.tryParse('${json['renews_at']}')?.toLocal(),
        card: json['card'] as String? ?? '',
        nextChargeNaira: json['next_charge_naira'] as int? ?? 0,
        isActive: json['is_active'] as bool? ?? false,
        autoRenew: json['auto_renew'] as bool? ?? true,
        trialAvailable: json['trial_available'] as bool? ?? true,
        trialRequiresCard: json['trial_requires_card'] as bool? ?? false,
        cardCheckNaira: json['card_check_naira'] as int? ?? 0,
      );
}

/// One line on Billing History.
class BillingInvoice {
  const BillingInvoice({
    required this.id,
    required this.amountNaira,
    required this.description,
    required this.statusLabel,
    this.paidAt,
  });

  final String id;
  final int amountNaira;
  final String description;

  /// "Paid (Mastercard 1234)" — the frame puts the card inside the pill.
  final String statusLabel;
  final DateTime? paidAt;

  factory BillingInvoice.fromJson(Map<String, dynamic> json) => BillingInvoice(
        id: '${json['id']}',
        amountNaira: json['amount_naira'] as int? ?? 0,
        description: json['description'] as String? ?? '',
        statusLabel: json['status_label'] as String? ?? '',
        paidAt: DateTime.tryParse('${json['paid_at']}')?.toLocal(),
      );
}
