/// One account the expert can be paid into — Figma "Bank GTransfer Details"
/// once it is filled, and the tiles under "Destination of funds" on the
/// withdrawal frame.
///
/// An expert can have several: the withdrawal frame draws three, which is why
/// this is a list rather than the single string the screens used to keep.
class BankDestination {
  const BankDestination({
    required this.bank,
    required this.accountNumber,
    required this.accountName,
  });

  final String bank;

  /// As typed. The frame writes it grouped ("0234 5678 890"), so this is kept
  /// verbatim and only [masked] goes near the digits.
  final String accountNumber;

  final String accountName;

  /// What the Earnings card's "Payout method" row shows — "Bank ****7890".
  ///
  /// The last four digits, with any grouping stripped first: the frame's own
  /// placeholder reads "Bank ****1234" while its saved card reads
  /// "0234 5678 890", so the two never agreed and the account on file wins.
  String get masked {
    final digits = accountNumber.replaceAll(RegExp(r'\D'), '');
    final tail = digits.length <= 4
        ? digits
        : digits.substring(digits.length - 4);
    return 'Bank ****$tail';
  }

  /// What the frame labels each destination tile beneath the bank's name.
  static const String kind = 'Bank Transfer';

  BankDestination copyWith({
    String? bank,
    String? accountNumber,
    String? accountName,
  }) =>
      BankDestination(
        bank: bank ?? this.bank,
        accountNumber: accountNumber ?? this.accountNumber,
        accountName: accountName ?? this.accountName,
      );
}
