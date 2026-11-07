import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soothifyafrica/app/core/utils/card_input.dart';

/// The card fields used to take anything: any length, any character, no
/// grouping and no complaint. These are the rules that replaced that.
void main() {
  String typed(TextInputFormatter f, String value) => f
      .formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: value),
      )
      .text;

  group('the card number', () {
    const formatter = CardNumberFormatter();

    test('is grouped in fours and stops at sixteen', () {
      expect(typed(formatter, '4242424242424242'), '4242 4242 4242 4242');
      // Anything past the brand's length is dropped rather than typed on.
      expect(typed(formatter, '42424242424242429999'), '4242 4242 4242 4242');
    });

    test('an Amex is grouped 4-6-5 and stops at fifteen', () {
      expect(typed(formatter, '378282246310005'), '3782 822463 10005');
      expect(typed(formatter, '3782822463100059999'), '3782 822463 10005');
    });

    test('letters and punctuation never land in the field', () {
      expect(typed(formatter, '4242-abc-4242!4242£4242'), '4242 4242 4242 4242');
    });

    test('a transposed pair is caught by the checksum', () {
      expect(cardNumberError('4242 4242 4242 4242'), isNull);
      // Two digits swapped: the right length, the wrong number.
      expect(cardNumberError('4242 4242 4242 4224'), 'Check the card number.');
    });

    test('a short number says so rather than failing the checksum', () {
      expect(cardNumberError('4242 4242'), 'That number is too short.');
      expect(cardNumberError(''), 'Enter the card number.');
    });
  });

  group('the expiry', () {
    const formatter = ExpiryFormatter();
    final now = DateTime(2026, 11);

    test('writes the slash itself', () {
      expect(typed(formatter, '1230'), '12 / 30');
      expect(typed(formatter, '1'), '1');
      // A lone digit that can only be a month gets its zero.
      expect(typed(formatter, '4'), '04');
    });

    test('never takes more than four digits', () {
      expect(typed(formatter, '123456'), '12 / 34');
    });

    test('a month that does not exist is refused', () {
      expect(expiryError('13 / 30', now: now), 'That month does not exist.');
      expect(expiryError('00 / 30', now: now), 'That month does not exist.');
    });

    test('a card is good through the last day of its month', () {
      // This month: still good.
      expect(expiryError('11 / 26', now: now), isNull);
      expect(expiryError('10 / 26', now: now), 'That card has expired.');
      expect(expiryError('12 / 26', now: now), isNull);
    });

    test('an implausible year is questioned', () {
      expect(expiryError('01 / 99', now: now), 'Check the expiry year.');
    });
  });

  group('the security code', () {
    test('is three digits, or four on an Amex', () {
      expect(securityCodeError('123', cardNumber: '4242424242424242'), isNull);
      expect(securityCodeError('12', cardNumber: '4242424242424242'),
          'The code is 3 digits.');
      expect(securityCodeError('1234', cardNumber: '378282246310005'), isNull);
      expect(securityCodeError('123', cardNumber: '378282246310005'),
          'The code is 4 digits.');
    });
  });

  group('the cardholder', () {
    test('is a name, not a number', () {
      expect(cardholderError('Dami Adeyemi'), isNull);
      expect(cardholderError('Dami 2'), 'A name has no digits in it.');
      expect(cardholderError(' '), 'Enter the name on the card.');
    });
  });

  group('the brand', () {
    test('is read off the first digits', () {
      expect(CardBrand.of('4242424242424242'), CardBrand.visa);
      expect(CardBrand.of('5555555555554444'), CardBrand.mastercard);
      expect(CardBrand.of('2223003122003222'), CardBrand.mastercard);
      expect(CardBrand.of('378282246310005'), CardBrand.amex);
      expect(CardBrand.of('9999'), CardBrand.unknown);
    });
  });
}
