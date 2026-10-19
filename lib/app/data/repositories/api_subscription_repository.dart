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

  /// Asked for a period on purpose.
  ///
  /// Core is two rows on the server — one monthly, one annual — and the
  /// endpoint only collapses them to the one being asked about when a
  /// period is named. Without it the Discovery card listed "Soothify Core"
  /// twice, at two prices, with nothing on either row to say which was
  /// which.
  ///
  /// Monthly, because that is what the Plans tab opens on; somebody who
  /// taps through to compare sees the same figure they were just shown, and
  /// the annual price is a toggle away.
  @override
  Future<List<SubscriptionPlan>> getPlans() async {
    final rows = await _api.getList(
      '/billing/plans/?period=${BillingPeriod.monthly.name}',
    );
    return rows.map(SubscriptionPlan.fromJson).toList();
  }

  @override
  Future<List<PlanTier>> getTiers(BillingPeriod period) async {
    final rows = await _api.getList('/billing/plans/?period=${period.name}');
    return rows.map(PlanTier.fromJson).toList();
  }
}
