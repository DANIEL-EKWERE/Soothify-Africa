import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/repositories/mock_billing_repository.dart';
import 'package:soothifyafrica/app/data/models/checkout.dart';
import 'package:soothifyafrica/app/data/models/membership.dart';
import 'package:soothifyafrica/app/data/repositories/billing_repository.dart';
import 'package:soothifyafrica/app/modules/user/subscription_manage/billing_history_screen.dart';
import 'package:soothifyafrica/app/modules/user/subscription_manage/change_plan_screen.dart';
import 'package:soothifyafrica/app/modules/user/subscription_manage/controller/subscription_manage_controller.dart';
import 'package:soothifyafrica/app/modules/user/subscription_manage/your_subscription_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/subscription_manage_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('subscription screens, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      final c = Get.put(SubscriptionManageController(MockBillingRepository()));

      // Active first, which is what the frame draws.
      await pumpScreen(tester, const YourSubscriptionScreen(),
          brightness: brightness);
      await settleLoads(tester);
      await expectLater(find.byType(YourSubscriptionScreen),
          matchesGoldenFile('goldens/subscription_active_$name.png'));

      c.state.value = SubscriptionState.inactive;
      await tester.pumpAndSettle();
      await expectLater(find.byType(YourSubscriptionScreen),
          matchesGoldenFile('goldens/subscription_inactive_$name.png'));

      await pumpScreen(tester, const ChangePlanScreen(),
          brightness: brightness);
      await settleLoads(tester);
      await expectLater(find.byType(ChangePlanScreen),
          matchesGoldenFile('goldens/subscription_change_plan_$name.png'));

      await pumpScreen(tester, const BillingHistoryScreen(),
          brightness: brightness);
      await settleLoads(tester);
      await expectLater(find.byType(BillingHistoryScreen),
          matchesGoldenFile('goldens/subscription_billing_$name.png'));

      // Nothing billed yet, which is the frame's other state.
      c.billingHistory.clear();
      await tester.pumpAndSettle();
      await expectLater(find.byType(BillingHistoryScreen),
          matchesGoldenFile('goldens/subscription_billing_empty_$name.png'));
    });
  }

  testWidgets('the active card says what is being paid, and how', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put(SubscriptionManageController(MockBillingRepository()));

    await pumpScreen(tester, const YourSubscriptionScreen());
    await settleLoads(tester);

    expect(find.text('Active · Free Trial'), findsOneWidget);
    expect(find.text('Subscription details'), findsOneWidget);
    expect(findSoothify('Soothify Annual Membership'), findsOneWidget);
    expect(find.text('₦150,000 / year'), findsOneWidget);
    expect(find.text('Mastercard ending in •••••'), findsOneWidget);
    expect(find.textContaining('free trial ends on October 9, 2026'),
        findsOneWidget);
    expect(find.text('Change Plan'), findsOneWidget);
    expect(find.text('Cancel Subscription'), findsOneWidget);
  });

  testWidgets('cancelling asks first, and keeping it is the easy answer',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = Get.put(SubscriptionManageController(MockBillingRepository()));

    await pumpScreen(tester, const YourSubscriptionScreen());
    await settleLoads(tester);
    await tester.tap(find.text('Cancel Subscription'));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to cancel?'), findsOneWidget);
    // The filled button keeps it; confirming is the quiet link.
    await tester.tap(find.text('Keep My Subscription'));
    await tester.pumpAndSettle();
    expect(c.state.value, SubscriptionState.trial);

    await tester.tap(find.text('Cancel Subscription'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm Cancellation'));
    await settleLoads(tester);
    expect(c.state.value, SubscriptionState.inactive);
    // And the screen turns into the inactive one.
    expect(find.text('Inactive'), findsOneWidget);
    expect(find.text('Start 7-Day Free Trial'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('billing history is empty until something is billed',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = Get.put(SubscriptionManageController(MockBillingRepository()));

    await pumpScreen(tester, const BillingHistoryScreen());
    await settleLoads(tester);
    expect(find.text('Oct 2, 2026'), findsOneWidget);
    expect(find.text('₦150,000'), findsOneWidget);
    expect(find.text('Paid (Mastercard •••••)'), findsOneWidget);

    // A receipt outlives the membership, so the empty state is about having
    // been billed nothing -- not about having cancelled.
    c.billingHistory.clear();
    await tester.pumpAndSettle();
    expect(find.text('No past invoices yet.'), findsOneWidget);
    expect(find.text('Oct 2, 2026'), findsNothing);
  });

  test('the two memberships, and which one claims a saving', () {
    expect(MembershipPlan.annual.hasSaving, isTrue);
    expect(MembershipPlan.annual.saving, 'Best value — save ₦15,000 a year');
    expect(MembershipPlan.annual.perMonth, '₦12,500 /mo');
    expect(MembershipPlan.annual.billed, '₦150,000 / year');
    expect(MembershipPlan.monthly.hasSaving, isFalse);
    expect(MembershipPlan.monthly.perMonth, '₦15,000 /mo');
  });

  test('confirming a plan change moves the live plan, not just the choice',
      () {
    Get.testMode = true;
    final c = Get.put(SubscriptionManageController(MockBillingRepository()));
    expect(c.plan.value, MembershipPlan.annual);

    c.choose(MembershipPlan.monthly);
    expect(c.canConfirmPlan, isTrue);
    // The live plan does not move until it is confirmed.
    expect(c.plan.value, MembershipPlan.annual);

    c.confirmPlanChange();
    expect(c.plan.value, MembershipPlan.monthly);
    expect(c.canConfirmPlan, isFalse);
  });

  group('a membership that does not renew itself', () {
    /// What the server says while memberships are sold a period at a time.
    SubscriptionManageController controllerFor(MembershipStatus status) =>
        Get.put(SubscriptionManageController(_FixedBilling(status)));

    test('the card says the membership ends, not that it renews', () async {
      Get.testMode = true;
      final c = controllerFor(MembershipStatus(
        state: 'active',
        planKey: 'core-annual',
        planName: 'Soothify Core',
        renewsAt: DateTime(2027, 10, 9),
        nextChargeNaira: 150000,
        isActive: true,
        autoRenew: false,
      ));

      await c.refreshMembership();

      // "Renews on" would leave somebody expecting access they are about to
      // lose, which is the one thing this screen must not do.
      expect(c.renewalCopy, contains('ends on October 9, 2027'));
      expect(c.renewalCopy, contains('Renew for ₦150,000'));
      expect(c.renewalCopy, isNot(contains('renews on')));
    });

    test('a free week with no card asks for payment before it ends', () async {
      Get.testMode = true;
      final c = controllerFor(MembershipStatus(
        state: 'trial',
        planName: 'Soothify Core',
        trialEndsAt: DateTime(2026, 10, 23),
        nextChargeNaira: 150000,
        isActive: true,
        autoRenew: false,
      ));

      await c.refreshMembership();

      expect(c.renewalCopy, contains('free trial ends on October 23, 2026'));
      expect(c.renewalCopy, contains('Pay ₦150,000 before then'));
    });

    test('the button stops offering a week that has been used', () async {
      Get.testMode = true;
      final used = controllerFor(const MembershipStatus(
        state: 'inactive',
        trialAvailable: false,
      ));

      await used.refreshMembership();

      expect(used.startLabel, 'Start Membership');
    });

    test('and still offers it to somebody who has not', () async {
      Get.testMode = true;
      final fresh = controllerFor(const MembershipStatus(state: 'inactive'));

      await fresh.refreshMembership();

      expect(fresh.startLabel, 'Start 7-Day Free Trial');
    });
  });
}

/// A billing server with one fixed answer.
class _FixedBilling implements BillingRepository {
  _FixedBilling(this._status);

  final MembershipStatus _status;

  @override
  Future<MembershipStatus> membership() async => _status;

  @override
  Future<Checkout> replaceCard() => throw UnimplementedError();

  @override
  Future<List<BillingInvoice>> invoices() async => const [];

  @override
  Future<MembershipStatus> cancelMembership() async => MembershipStatus.none;

  @override
  Future<Checkout> startMembership({
    required String planKey,
    String cadence = 'annual',
    bool trial = true,
    String promoCode = '',
  }) =>
      throw UnimplementedError();

  @override
  Future<Checkout> paySession(String sessionId, {String promoCode = ''}) =>
      throw UnimplementedError();

  @override
  Future<String> paymentStatus(String reference) async => 'pending';

  @override
  Future<Map<String, dynamic>?> checkPromo(String code) async => null;
}
