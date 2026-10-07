import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/membership.dart';
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
      final c = Get.put(SubscriptionManageController());

      // Active first, which is what the frame draws.
      await pumpScreen(tester, const YourSubscriptionScreen(),
          brightness: brightness);
      await expectLater(find.byType(YourSubscriptionScreen),
          matchesGoldenFile('goldens/subscription_active_$name.png'));

      c.state.value = SubscriptionState.inactive;
      await tester.pumpAndSettle();
      await expectLater(find.byType(YourSubscriptionScreen),
          matchesGoldenFile('goldens/subscription_inactive_$name.png'));

      await pumpScreen(tester, const ChangePlanScreen(),
          brightness: brightness);
      await expectLater(find.byType(ChangePlanScreen),
          matchesGoldenFile('goldens/subscription_change_plan_$name.png'));

      // Inactive, so Billing History shows its empty state.
      await pumpScreen(tester, const BillingHistoryScreen(),
          brightness: brightness);
      await expectLater(find.byType(BillingHistoryScreen),
          matchesGoldenFile('goldens/subscription_billing_empty_$name.png'));

      c.state.value = SubscriptionState.trial;
      await tester.pumpAndSettle();
      await expectLater(find.byType(BillingHistoryScreen),
          matchesGoldenFile('goldens/subscription_billing_$name.png'));
    });
  }

  testWidgets('the active card says what is being paid, and how', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put(SubscriptionManageController());

    await pumpScreen(tester, const YourSubscriptionScreen());

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
    final c = Get.put(SubscriptionManageController());

    await pumpScreen(tester, const YourSubscriptionScreen());
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
    await tester.pumpAndSettle();
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
    final c = Get.put(SubscriptionManageController());

    await pumpScreen(tester, const BillingHistoryScreen());
    expect(find.text('Oct 2, 2026'), findsOneWidget);
    expect(find.text('₦150,000'), findsOneWidget);
    expect(find.text('Paid (Mastercard •••••)'), findsOneWidget);

    c.state.value = SubscriptionState.inactive;
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
    final c = Get.put(SubscriptionManageController());
    expect(c.plan.value, MembershipPlan.annual);

    c.choose(MembershipPlan.monthly);
    expect(c.canConfirmPlan, isTrue);
    // The live plan does not move until it is confirmed.
    expect(c.plan.value, MembershipPlan.annual);

    c.confirmPlanChange();
    expect(c.plan.value, MembershipPlan.monthly);
    expect(c.canConfirmPlan, isFalse);
  });
}
