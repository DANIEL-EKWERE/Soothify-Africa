/// One bank a payout account can be at.
///
/// The list comes from Bachs rather than being written into the app: a list
/// of Nigerian banks goes out of date, and the code is what their account
/// lookup expects — a name alone cannot be resolved.
class BankOption {
  const BankOption({required this.code, required this.name});

  final String code;
  final String name;

  factory BankOption.fromJson(Map<String, dynamic> json) => BankOption(
        code: json['code'] as String? ?? '',
        name: json['name'] as String? ?? '',
      );
}
