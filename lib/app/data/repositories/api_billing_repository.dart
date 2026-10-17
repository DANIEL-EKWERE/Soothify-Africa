import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/checkout.dart';
import 'billing_repository.dart';

/// Billing against `/api/v1/billing/`.
class ApiBillingRepository implements BillingRepository {
  ApiBillingRepository(this._api);

  final ApiClient _api;

  @override
  Future<MembershipStatus> membership() async {
    final body = await _api.get('/billing/membership/');
    return MembershipStatus.fromJson(body);
  }

  @override
  Future<Checkout> startMembership({
    required String planKey,
    String cadence = 'annual',
    bool trial = true,
    String promoCode = '',
  }) async {
    final body = await _api.post('/billing/checkout/', body: {
      'plan': planKey,
      'cadence': cadence,
      'trial': trial,
      if (promoCode.isNotEmpty) 'promo_code': promoCode,
    });
    return Checkout.fromJson(body);
  }

  @override
  Future<Checkout> paySession(String sessionId, {String promoCode = ''}) async {
    final body = await _api.post(
      '/billing/sessions/$sessionId/checkout/',
      body: {if (promoCode.isNotEmpty) 'promo_code': promoCode},
    );
    return Checkout.fromJson(body);
  }

  @override
  Future<String> paymentStatus(String reference) async {
    final body = await _api.get('/billing/payments/$reference/');
    return body['status'] as String? ?? 'pending';
  }

  @override
  Future<MembershipStatus> cancelMembership() async {
    final body = await _api.post('/billing/membership/cancel/');
    return MembershipStatus.fromJson(body);
  }

  @override
  Future<Checkout> replaceCard() async =>
      Checkout.fromJson(await _api.post('/billing/card/'));

  @override
  Future<List<BillingInvoice>> invoices() async {
    final rows = await _api.getList('/billing/invoices/');
    return rows.map(BillingInvoice.fromJson).toList();
  }

  @override
  Future<Map<String, dynamic>?> checkPromo(String code) async {
    try {
      final body = await _api.post('/billing/promo/', body: {'code': code});
      return body['valid'] == true ? body : null;
    } on NotFoundException {
      // "That code cannot be used" is an answer, not a failure.
      return null;
    }
  }
}
