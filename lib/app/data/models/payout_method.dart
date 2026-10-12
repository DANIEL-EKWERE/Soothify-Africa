import 'package:flutter/material.dart';

/// How an expert is paid — Figma "Payout method" (`259:59463`, filed in the
/// file under the name "Recent payouts").
///
/// The same three appear as full cards there and as compact tiles on the
/// withdrawal screen (`259:59559`), so both the long blurb and the short
/// account line live here.
enum PayoutMethod {
  bankTransfer(
    'Bank Transfer',
    'Receive payment directly into your Nigerian bank account',
    account: 'Access Bank',
  ),
  paystackCard(
    'Paystack Card',
    // The frame writes "Naria".
    'Get paid directly into your debit card (Naira).',
  ),
  mobileMoney(
    'Mobile Money (USSD)',
    // The frame leaves the bracket open: "(select network".
    'Receive payment via your mobile wallet (select network)',
  );

  const PayoutMethod(this.label, this.blurb, {this.account});

  /// What the chooser actually puts in front of an expert.
  ///
  /// The screens this flow goes through draw Bank Transfer alone — it is the
  /// only one with a form and a destination behind it. The other two keep
  /// their copy here for the earlier frame and for when their own screens
  /// arrive, rather than offering a choice that dead-ends in "not built yet".
  static const List<PayoutMethod> offered = [PayoutMethod.bankTransfer];

  final String label;

  final String blurb;

  /// The destination's own name, when there is one to show. Only Bank
  /// Transfer carries one in the frame — the other two tiles have no room,
  /// because their labels already wrap to two lines.
  final String? account;

  /// The mark the frame puts beside each method. The providers' own logos
  /// were never exported, so these stand in.
  IconData get glyph => switch (this) {
        PayoutMethod.bankTransfer => Icons.account_balance,
        PayoutMethod.paystackCard => Icons.credit_card,
        PayoutMethod.mobileMoney => Icons.smartphone,
      };
}
