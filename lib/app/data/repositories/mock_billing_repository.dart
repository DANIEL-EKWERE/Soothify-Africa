import '../models/checkout.dart';
import 'billing_repository.dart';

/// Billing without a server.
///
/// Never claims money moved: checkout returns an empty URL, which the
/// screens read as "payments are not connected".
///
/// It does report the membership the Manage-subscription frames draw --
/// an annual trial, its card and its first invoice -- because those screens
/// are nothing without one, and the dates are fixed rather than relative so
/// a golden taken today still matches next month.
class MockBillingRepository implements BillingRepository {
  static const _latency = Duration(milliseconds: 300);

  /// The state of `308:25746`: a free trial on the annual plan, ending on
  /// the 9th, with the first charge due then.
  static final MembershipStatus _trial = MembershipStatus(
    state: 'trial',
    planKey: 'core-annual',
    planName: 'Soothify Annual Membership',
    cadence: 'annual',
    trialEndsAt: DateTime(2026, 10, 9),
    card: 'Mastercard ending in \u2022\u2022\u2022\u2022\u2022',
    nextChargeNaira: 150000,
    isActive: true,
  );

  MembershipStatus _membership = _trial;

  @override
  Future<MembershipStatus> membership() async {
    await Future<void>.delayed(_latency);
    return _membership;
  }

  @override
  Future<Checkout> startMembership({
    required String planKey,
    String cadence = 'annual',
    bool trial = true,
    String promoCode = '',
  }) async {
    await Future<void>.delayed(_latency);
    return Checkout(
      reference: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      checkoutUrl: '',
      amountNaira: cadence == 'annual' ? 150000 : 15000,
      trialDays: trial ? 7 : 0,
      dueTodayNaira: trial ? 0 : (cadence == 'annual' ? 150000 : 15000),
    );
  }

  @override
  Future<Checkout> paySession(String sessionId, {String promoCode = ''}) async {
    await Future<void>.delayed(_latency);
    return Checkout(
      reference: 'mock-session-$sessionId',
      checkoutUrl: '',
      amountNaira: 25000,
    );
  }

  @override
  Future<String> paymentStatus(String reference) async => 'pending';

  @override
  Future<MembershipStatus> cancelMembership() async {
    await Future<void>.delayed(_latency);
    _membership = MembershipStatus.none;
    return _membership;
  }

  @override
  Future<Checkout> replaceCard() async {
    await Future<void>.delayed(_latency);
    // No provider, so no checkout to open. The screen reads an empty URL
    // as "payments are not connected", which is the truth here.
    return const Checkout(reference: '', checkoutUrl: '', amountNaira: 0);
  }

  @override
  Future<List<BillingInvoice>> invoices() async {
    await Future<void>.delayed(_latency);
    // The two rows `308:25859` prints: the annual charge that followed the
    // trial, and the monthly one before it. Kept after a cancellation, as
    // the server keeps them -- a receipt is not undone by leaving.
    return [
      BillingInvoice(
        id: '2',
        amountNaira: 150000,
        description:
            'Soothify Annual Membership (7-Day Trial Ended / First Charge)',
        statusLabel: 'Paid (Mastercard \u2022\u2022\u2022\u2022\u2022)',
        paidAt: DateTime(2026, 10, 2),
      ),
      BillingInvoice(
        id: '1',
        amountNaira: 15000,
        description: 'Soothify Monthly Membership',
        statusLabel: 'Paid',
        paidAt: DateTime(2025, 10, 2),
      ),
    ];
  }

  @override
  Future<Map<String, dynamic>?> checkPromo(String code) async => null;
}
