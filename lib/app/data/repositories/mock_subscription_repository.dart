import '../models/plan_tier.dart';
import '../models/subscription_plan.dart';
import 'subscription_repository.dart';

/// The three tiers the design names, at the prices it prints.
class MockSubscriptionRepository implements SubscriptionRepository {
  static const _latency = Duration(milliseconds: 400);

  static const List<SubscriptionPlan> _plans = [
    // The same three tiers Plans sells, named the same way. They used to be
    // "One time / Basic / Pro", which named nothing the rest of the app knew.
    SubscriptionPlan(
      id: 'core',
      label: 'Soothify Core',
      price: 'NGN 5,000 / day',
    ),
    SubscriptionPlan(
      id: 'passport',
      label: 'Soothify Passport',
      price: 'NGN 5,000 / day',
    ),
    SubscriptionPlan(
      id: 'corporate',
      label: 'Soothify Corporate Wellness',
      price: 'NGN 5,000 / day',
    ),
  ];

  /// The three the designer redrew on 2026-10-02: one priced tier, one
  /// waitlisted, one that routes to a conversation rather than a checkout.
  static const List<PlanTier> _tiers = [
    PlanTier(
      id: 'core',
      name: 'Soothify Core',
      description: 'Your sanctuary for daily balance. Includes unlimited '
          'streaming of our video library, sleep stories, soothing '
          'soundscapes, and the wellness journal.',
      price: '₦15,000',
      priceSuffix: '/One time access',
    ),
    PlanTier(
      id: 'passport',
      name: 'Soothify Passport',
      description: 'Your city-wide pass to physical movement. Enjoy 6 curated '
          'class bookings monthly across boutique studios, gyms, and '
          'sanctuaries in Abuja and Lagos (fully inclusive of your Core '
          'digital access).',
      action: PlanAction.waitlist,
      emphasised: true,
    ),
    PlanTier(
      id: 'corporate',
      name: 'Soothify Corporate Wellness',
      description: 'Tailored holistic care designed to nurture your entire '
          'team. Bring mindful movement, stress relief, and restorative '
          'wellness directly into your workplace culture.',
      action: PlanAction.corporate,
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
