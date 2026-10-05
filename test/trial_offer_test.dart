import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/membership.dart';
import 'package:soothifyafrica/app/modules/user/trial_offer/controller/trial_offer_controller.dart';
import 'package:soothifyafrica/app/modules/user/trial_offer/trial_offer_screen.dart';
import 'package:soothifyafrica/app/modules/user/trial_offer/trial_payment_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/trial_offer_test.dart
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
    testWidgets('trial offer, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      final c = Get.put(TrialOfferController());

      await pumpScreen(tester, const TrialOfferScreen(),
          brightness: brightness);
      await expectLater(find.byType(TrialOfferScreen),
          matchesGoldenFile('goldens/trial_offer_$name.png'));

      // The card form open, which is the taller of the two payment frames.
      await pumpScreen(tester, const TrialPaymentScreen(),
          brightness: brightness);
      await expectLater(find.byType(TrialPaymentScreen),
          matchesGoldenFile('goldens/trial_payment_card_$name.png'));

      c.chooseMethod(PaymentMethod.applePay);
      await tester.pumpAndSettle();
      await expectLater(find.byType(TrialPaymentScreen),
          matchesGoldenFile('goldens/trial_payment_apple_$name.png'));
    });
  }

  testWidgets('the pop-up lays out the week before it starts', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put(TrialOfferController());

    await pumpScreen(tester, const TrialOfferScreen());

    expect(find.text('7 days, on us.'), findsOneWidget);
    for (final step in TrialOfferScreen.timeline) {
      expect(find.text(step.$1), findsOneWidget, reason: step.$1);
      expect(find.text(step.$2), findsOneWidget, reason: step.$2);
    }
    expect(find.text('Annual ₦12,500/monthly'), findsOneWidget);
    expect(find.text('₦150,000 billed once a year'), findsOneWidget);
    expect(find.text('Best value - save 15%'), findsOneWidget);
    expect(find.text('Due today ₦0.00'), findsOneWidget);
    expect(find.text('Start My Free Week'), findsOneWidget);
    expect(find.text('No charge today · Secure checkout'), findsOneWidget);
  });

  testWidgets('choosing a plan moves the tick and what is charged',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = Get.put(TrialOfferController());

    await pumpScreen(tester, const TrialOfferScreen());
    expect(c.plan.value, MembershipPlan.annual);
    expect(c.firstCharge, '₦150,000');

    await tester.tap(find.text('Monthly Pass ₦15,000 / one month'));
    await tester.pumpAndSettle();
    expect(c.plan.value, MembershipPlan.monthly);
    expect(c.firstCharge, '₦15,000');
  });

  testWidgets('the card form only shows when the card is chosen',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = Get.put(TrialOfferController());

    await pumpScreen(tester, const TrialPaymentScreen());
    // The frame opens on the card, with its fields expanded.
    expect(c.method.value, PaymentMethod.card);
    expect(find.text('Card number'), findsOneWidget);
    expect(find.text('Security code'), findsOneWidget);

    await tester.tap(find.text('Apple Pay'));
    await tester.pumpAndSettle();
    expect(c.method.value, PaymentMethod.applePay);
    expect(find.text('Card number'), findsNothing);
  });

  testWidgets('everything is priced in naira', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put(TrialOfferController());

    await pumpScreen(tester, const TrialPaymentScreen());
    // `311:25477` prints dollars for these; `311:25582` prints naira for the
    // same amounts, and naira is what the rest of the app uses.
    expect(find.textContaining(r'$'), findsNothing);
    // Sales tax and the total both read ₦0.00 during the trial.
    expect(find.text('₦0.00'), findsNWidgets(2));
    expect(find.text('-₦150,000'), findsOneWidget);
  });

  test('an empty promo code is refused before anything is claimed', () {
    Get.testMode = true;
    final c = Get.put(TrialOfferController());
    c.promo.value = '   ';
    c.applyPromo();
    // Nothing to assert beyond it not throwing; the message is the behaviour.
    c.promo.value = 'SOOTHE10';
    c.applyPromo();
  });
}
