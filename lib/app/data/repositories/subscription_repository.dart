import '../models/plan_tier.dart';
import '../models/subscription_plan.dart';

/// Subscription tiers, shared by the Discovery upsell card and the Plans tab.
abstract class SubscriptionRepository {
  /// The compact label-and-price rows in the Discovery upsell card.
  Future<List<SubscriptionPlan>> getPlans();

  /// The full plan cards on the Plans screen, for a billing period.
  Future<List<PlanTier>> getTiers(BillingPeriod period);
}
