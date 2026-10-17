import '../models/checkout.dart';

/// Memberships, checkout and what has been charged.
///
/// Nothing here takes money: the server starts a payment with the provider
/// and the app opens the URL that comes back. Whether it succeeded is the
/// webhook's business, which is why [paymentStatus] exists.
abstract class BillingRepository {
  Future<MembershipStatus> membership();

  /// Start a membership. With [trial] the card is saved and nothing is
  /// charged today.
  Future<Checkout> startMembership({
    required String planKey,
    String cadence = 'annual',
    bool trial = true,
    String promoCode = '',
  });

  /// Pay for a session that is holding a slot.
  Future<Checkout> paySession(String sessionId, {String promoCode = ''});

  /// What the server has recorded for this payment: 'pending', 'paid' or
  /// 'failed'. The app polls it after checkout rather than believing the
  /// browser's redirect.
  Future<String> paymentStatus(String reference);

  Future<MembershipStatus> cancelMembership();

  /// Starts changing the card on file. Returns a checkout to open.
  ///
  /// There is no quieter way: a card is only saved while it is charged, so
  /// replacing one means charging the new one the provider's smallest
  /// amount -- which is given straight back. The amount is on the
  /// [Checkout], so the screen can say what will happen before it opens.
  Future<Checkout> replaceCard();

  Future<List<BillingInvoice>> invoices();

  /// What a promo code is worth, before anyone commits to paying. Null when
  /// it cannot be used.
  Future<Map<String, dynamic>?> checkPromo(String code);
}
