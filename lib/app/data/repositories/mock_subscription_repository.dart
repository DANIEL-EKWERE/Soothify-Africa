import '../models/plan_tier.dart';
import '../models/subscription_plan.dart';
import 'subscription_repository.dart';

/// The three tiers the design names, at the prices it prints.
class MockSubscriptionRepository implements SubscriptionRepository {
  static const _latency = Duration(milliseconds: 400);

  static const List<SubscriptionPlan> _plans = [
    SubscriptionPlan(id: 'one-time', label: 'One time', price: 'NGN 5,000 / day'),
    SubscriptionPlan(id: 'basic', label: 'Basic', price: 'NGN 5,000 / day'),
    SubscriptionPlan(id: 'pro', label: 'Pro', price: 'NGN 5,000 / day'),
  ];

  /// The design prints the same price on all three cards and the same copy on
  /// two of them. That is placeholder content in the file, reproduced as-is
  /// rather than invented around.
  static const List<PlanTier> _tiers = [
    PlanTier(
      id: 'one-off',
      name: 'One-Off Plan',
      description: 'One-time access, Experience selected features and '
          'resources, Perfect for testing Soothify',
      price: '₦15,000/One time access',
    ),
    PlanTier(
      id: 'pro',
      name: 'Pro Plan',
      description: 'Custom wellness programs for organizations, Group therapy '
          'sessions, Team mindfulness and relaxation',
      price: '₦15,000/One time access',
      emphasised: true,
    ),
    PlanTier(
      id: 'corporate',
      name: 'Corporate Plan',
      description: 'Custom wellness programs for organizations, Group therapy '
          'sessions, Team mindfulness and relaxation exercises',
      price: '₦15,000/One time access',
    ),
  ];

  @override
  Future<List<SubscriptionPlan>> getPlans() async {
    await Future<void>.delayed(_latency);
    return _plans;
  }

  /// The file has an Annual frame but prices it identically, so the period
  /// does not change the figures yet — the real ones come from the backend.
  @override
  Future<List<PlanTier>> getTiers(BillingPeriod period) async {
    await Future<void>.delayed(_latency);
    return _tiers;
  }
}
