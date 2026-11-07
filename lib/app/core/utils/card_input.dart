/// Formatting and checking for the card fields on the payment screen.
///
/// Kept out of the widget so the rules can be tested without pumping a
/// screen, and so the same rules apply wherever a card is typed.
///
/// None of this proves a card is good — only the issuer knows that. It
/// catches the typo before the payment page does, which is the difference
/// between "check the number" now and a declined charge later.
library;

import 'package:flutter/services.dart';

/// What the first digits say the card is. Only the three that change how
/// the number is grouped or how long the code is.
enum CardBrand {
  visa(16, 3),
  mastercard(16, 3),
  amex(15, 4),
  unknown(19, 4);

  const CardBrand(this.digits, this.codeLength);

  /// How many digits the number has.
  final int digits;

  /// How many the security code has — Amex prints four.
  final int codeLength;

  static CardBrand of(String digits) {
    if (digits.startsWith('4')) return CardBrand.visa;
    if (digits.length >= 2) {
      final two = int.tryParse(digits.substring(0, 2)) ?? 0;
      if (two == 34 || two == 37) return CardBrand.amex;
      if (two >= 51 && two <= 55) return CardBrand.mastercard;
    }
    if (digits.length >= 4) {
      final four = int.tryParse(digits.substring(0, 4)) ?? 0;
      if (four >= 2221 && four <= 2720) return CardBrand.mastercard;
    }
    return CardBrand.unknown;
  }
}

/// Digits only, grouped as the brand prints them: 4-4-4-4, or 4-6-5 on an
/// Amex.
class CardNumberFormatter extends TextInputFormatter {
  const CardNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = onlyDigits(newValue.text);
    final brand = CardBrand.of(digits);
    final capped = digits.length > brand.digits
        ? digits.substring(0, brand.digits)
        : digits;

    final groups = brand == CardBrand.amex ? const [4, 6, 5] : const [4, 4, 4, 4];
    final out = StringBuffer();
    var at = 0;
    for (final size in groups) {
      if (at >= capped.length) break;
      if (at > 0) out.write(' ');
      out.write(capped.substring(at, (at + size).clamp(0, capped.length)));
      at += size;
    }
    final text = out.toString();
    return TextEditingValue(
      text: text,
      // The caret goes to the end: a card number is typed left to right,
      // and chasing the old offset through inserted spaces puts it in the
      // middle of a group.
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// "MM / YY", built as the digits arrive.
class ExpiryFormatter extends TextInputFormatter {
  const ExpiryFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = onlyDigits(newValue.text);
    if (digits.length > 4) digits = digits.substring(0, 4);

    // A lone 2–9 can only be a month if it is 02–09, so the zero is
    // written for them rather than rejecting the keystroke.
    if (digits.length == 1 && int.parse(digits) > 1) digits = '0$digits';

    final text = digits.length <= 2
        ? digits
        : '${digits.substring(0, 2)} / ${digits.substring(2)}';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

String onlyDigits(String value) => value.replaceAll(RegExp(r'\D'), '');

/// Whether the digits pass the checksum every card number carries.
///
/// This is what catches a transposed pair — the commonest way a number is
/// mistyped, and one that no length check would notice.
bool passesLuhn(String digits) {
  if (digits.length < 12) return false;
  var sum = 0;
  var double = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    var n = digits.codeUnitAt(i) - 0x30;
    if (n < 0 || n > 9) return false;
    if (double) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    double = !double;
  }
  return sum % 10 == 0;
}

/// What is wrong with the card number, or null when nothing is.
String? cardNumberError(String value) {
  final digits = onlyDigits(value);
  if (digits.isEmpty) return 'Enter the card number.';
  final brand = CardBrand.of(digits);
  if (digits.length < brand.digits) return 'That number is too short.';
  if (!passesLuhn(digits)) return 'Check the card number.';
  return null;
}

/// What is wrong with "MM / YY", or null.
///
/// [now] is injectable so a test does not depend on the month it runs in.
String? expiryError(String value, {DateTime? now}) {
  final digits = onlyDigits(value);
  if (digits.isEmpty) return 'Enter the expiry date.';
  if (digits.length < 4) return 'Use MM / YY.';

  final month = int.parse(digits.substring(0, 2));
  final year = 2000 + int.parse(digits.substring(2));
  if (month < 1 || month > 12) return 'That month does not exist.';

  // A card is good through the last day of its month, so the comparison is
  // against the first of the next one.
  final at = now ?? DateTime.now();
  final expires = DateTime(year, month + 1);
  if (!expires.isAfter(DateTime(at.year, at.month))) {
    return 'That card has expired.';
  }
  if (year > at.year + 20) return 'Check the expiry year.';
  return null;
}

/// What is wrong with the security code, or null. Amex prints four digits;
/// everything else prints three.
String? securityCodeError(String value, {String cardNumber = ''}) {
  final digits = onlyDigits(value);
  final wanted = CardBrand.of(onlyDigits(cardNumber)).codeLength;
  if (digits.isEmpty) return 'Enter the security code.';
  if (digits.length != wanted) return 'The code is $wanted digits.';
  return null;
}

/// The name as the card prints it. Letters, spaces and the punctuation a
/// name can carry — a digit here is always a mistake.
String? cardholderError(String value) {
  final name = value.trim();
  if (name.isEmpty) return 'Enter the name on the card.';
  if (name.length < 2) return 'That name is too short.';
  if (RegExp(r'[0-9]').hasMatch(name)) return 'A name has no digits in it.';
  return null;
}
