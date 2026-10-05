/// The two memberships "Change Your Plan" offers — Figma `308:25888`.
enum MembershipPlan {
  annual(
    name: 'Annual Membership',
    brandedName: 'Soothify Annual Membership',
    perMonth: '₦12,500 /mo',
    cadence: '(billed as ₦150,000 once a year)',
    billed: '₦150,000 / year',
    saving: 'Best value — save ₦15,000 a year',
    offerTitle: 'Annual ₦12,500/monthly',
    offerSub: '₦150,000 billed once a year',
    offerSaving: 'Best value - save 15%',
  ),
  monthly(
    name: 'Monthly Membership',
    brandedName: 'Soothify Monthly Membership',
    perMonth: '₦15,000 /mo',
    cadence: '',
    billed: '₦15,000 / month',
    saving: '',
    offerTitle: 'Monthly Pass ₦15,000 / one month',
    offerSub: '',
    offerSaving: '',
  );

  const MembershipPlan({
    required this.name,
    required this.brandedName,
    required this.perMonth,
    required this.cadence,
    required this.billed,
    required this.saving,
    required this.offerTitle,
    required this.offerSub,
    required this.offerSaving,
  });

  /// How the picker names it — Figma `308:25888`.
  final String name;

  /// How "Your Subscription" and Billing History name it, which carries the
  /// brand — `308:25763` and `308:25859`.
  final String brandedName;

  /// The headline price, always per month so the two compare.
  final String perMonth;

  /// What is actually charged, where that differs from [perMonth].
  final String cadence;

  /// How the membership reads on "Your Subscription".
  final String billed;

  /// The badge above the name. Empty on the plan that has nothing to claim.
  final String saving;

  /// How the trial pop-up words the same plan — Figma `311:25655` says
  /// "Annual ₦12,500/monthly" and "Best value - save 15%" where the picker
  /// says "Annual Membership" and "save ₦15,000 a year".
  final String offerTitle;
  final String offerSub;
  final String offerSaving;

  bool get hasSaving => saving.isNotEmpty;
}

/// Where the account stands — Figma draws the first two as whole screens and
/// the third as a card over the second.
enum SubscriptionState { inactive, trial, active }

/// One line on Billing History — Figma `308:25859`.
class Invoice {
  const Invoice({
    required this.date,
    required this.amount,
    required this.description,
    required this.status,
  });

  final String date;
  final String amount;
  final String description;

  /// "Paid (Mastercard •••••)" — the frame puts the card inside the pill.
  final String status;

  /// The frame's own two rows: the annual charge that followed the trial, and
  /// the monthly one before it.
  static const List<Invoice> sample = [
    Invoice(
      date: 'Oct 2, 2026',
      amount: '₦150,000',
      description:
          'Soothify Annual Membership (7-Day Trial Ended / First Charge)',
      status: 'Paid (Mastercard •••••)',
    ),
    Invoice(
      date: 'Oct 2, 2025',
      amount: '₦15,000',
      description: 'Soothify Monthly Membership',
      status: 'Paid',
    ),
  ];
}
