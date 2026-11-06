/// One card on "Soothify Passport tier selection" — Figma `4958:26661`.
///
/// A class pack, not the Core subscription: a month's allowance of studio
/// bookings with a cap on how many may be Reformer. The frame sells three.
///
/// The copy is the frame's, verbatim — including the parenthetical third
/// line, which reads as a footnote but is a full sentence in the design.
class PassportTier {
  const PassportTier({
    required this.key,
    required this.name,
    required this.level,
    required this.priceNaira,
    required this.priceLabel,
    required this.practitioner,
    required this.allowance,
    required this.reformerLimit,
    required this.remainder,
    this.emphasised = false,
  });

  /// What the server sells it as. The plan key checkout is started with —
  /// see BillingRepository.startMembership.
  final String key;

  final String name;

  /// "Tier 1" — the outlined pill at the card's right.
  final String level;

  /// For the checkout, and for anything that has to compare the three.
  final int priceNaira;

  /// As the frame writes it, spaces and all: "₦90,000 / month".
  final String priceLabel;

  /// "Beginners testing out Pilates, yoga, and movement."
  final String practitioner;

  /// "6 Classes Total".
  final String allowance;

  /// "Max 2 Reformer sessions included".
  final String reformerLimit;

  /// "(Remaining 4 can be Mat, Yoga, or standard wellness classes)."
  final String remainder;

  /// The frame fills the middle card `#0A399A` and reverses its text. That
  /// is emphasis, not selection — nothing on the frame is selected.
  final bool emphasised;

  /// The frame names the tier in its own button rather than repeating
  /// "Select" three times.
  String get action => 'Select $name';

  /// The three the design draws.
  ///
  /// Held here rather than fetched because nothing serves them yet: the
  /// `passport` plan on the server is a single waitlist card with no price
  /// and no product behind it. [fromJson] is what the server will fill once
  /// the three products exist.
  static const List<PassportTier> all = [
    PassportTier(
      key: 'passport-starter',
      name: 'Starter Flow',
      level: 'Tier 1',
      priceNaira: 90000,
      priceLabel: '₦90,000 / month',
      practitioner: 'Beginners testing out Pilates, yoga, and movement.',
      allowance: '6 Classes Total',
      reformerLimit: 'Max 2 Reformer sessions included',
      remainder:
          '(Remaining 4 can be Mat, Yoga, or standard wellness classes).',
    ),
    PassportTier(
      key: 'passport-habit',
      name: 'Habit Builder',
      level: 'Tier 2',
      priceNaira: 125000,
      priceLabel: '₦125,000 / month',
      practitioner: 'Regular practitioners building a consistent routine.',
      allowance: '8 Classes Total',
      reformerLimit: 'Max 3 Reformer sessions included',
      remainder:
          '(Remaining 5 can be Mat, Yoga, or standard wellness classes).',
      emphasised: true,
    ),
    PassportTier(
      key: 'passport-pro',
      name: 'Pro Flow',
      level: 'Tier 3',
      priceNaira: 195000,
      priceLabel: '₦195,000 / month',
      practitioner: 'Seasoned practitioners fully immersed in their flow.',
      allowance: '12 Classes Total',
      reformerLimit: 'Max 5 Reformer sessions included',
      remainder:
          '(Remaining 7 can be Mat, Yoga, or standard wellness classes).',
    ),
  ];

  factory PassportTier.fromJson(Map<String, dynamic> json) => PassportTier(
        key: '${json['key'] ?? ''}',
        name: json['name'] as String? ?? '',
        level: json['level'] as String? ?? '',
        priceNaira: json['price_naira'] as int? ?? 0,
        priceLabel: json['price_display'] as String? ?? '',
        practitioner: json['description'] as String? ?? '',
        allowance: json['allowance'] as String? ?? '',
        reformerLimit: json['reformer_limit'] as String? ?? '',
        remainder: json['remainder'] as String? ?? '',
        emphasised: json['is_recommended'] as bool? ?? false,
      );
}
