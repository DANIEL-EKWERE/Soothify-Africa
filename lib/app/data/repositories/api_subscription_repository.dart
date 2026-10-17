import '../../core/network/api_client.dart';
import '../models/plan_tier.dart';
import '../models/subscription_plan.dart';
import 'subscription_repository.dart';

/// Plans, from `/api/v1/billing/plans/`.
///
/// The same rows back both screens: the Discovery upsell shows a label and a
/// price, the Plans screen shows the whole card. One endpoint, two readings.
class ApiSubscriptionRepository implements SubscriptionRepository {
  ApiSubscriptionRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<SubscriptionPlan>> getPlans() async {
    final rows = await _api.getList('/billing/plans/');
    return rows.map(SubscriptionPlan.fromJson).toList();
  }

  @override
  Future<List<PlanTier>> getTiers(BillingPeriod period) async {
    final rows = await _api.getList('/billing/plans/?period=${period.name}');
    return rows.map(PlanTier.fromJson).toList();
  }
}
