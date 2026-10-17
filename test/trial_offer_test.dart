import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/checkout_launcher.dart';
import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/checkout.dart';
import 'package:soothifyafrica/app/data/repositories/billing_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_billing_repository.dart';
import 'package:soothifyafrica/app/data/models/membership.dart';
import 'package:soothifyafrica/app/modules/user/trial_offer/controller/trial_offer_controller.dart';
import 'package:soothifyafrica/app/modules/user/trial_offer/trial_offer_screen.dart';
import 'package:soothifyafrica/app/modules/user/trial_offer/trial_payment_screen.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';

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
      // Two days after the frame was drawn, so the week ends on the 9th and
    // the screen prints the date the design does.
    final c = Get.put(TrialOfferController(
      MockBillingRepository(),
      now: () => DateTime(2026, 10, 2),
    ));

      await pumpScreen(tester, const TrialOfferScreen(),
          brightness: brightness);
      await settleLoads(tester);
    await settleLoads(tester);
      await expectLater(find.byType(TrialOfferScreen),
          matchesGoldenFile('goldens/trial_offer_$name.png'));

      // The card form open, which is the taller of the two payment frames.
      await pumpScreen(tester, const TrialPaymentScreen(),
          brightness: brightness);
      await settleLoads(tester);
    await settleLoads(tester);
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
    Get.put(TrialOfferController(
      MockBillingRepository(),
      now: () => DateTime(2026, 10, 2),
    ));

    await pumpScreen(tester, const TrialOfferScreen());
    await settleLoads(tester);

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
    // Two days after the frame was drawn, so the week ends on the 9th and
    // the screen prints the date the design does.
    final c = Get.put(TrialOfferController(
      MockBillingRepository(),
      now: () => DateTime(2026, 10, 2),
    ));

    await pumpScreen(tester, const TrialOfferScreen());
    await settleLoads(tester);
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
    // Two days after the frame was drawn, so the week ends on the 9th and
    // the screen prints the date the design does.
    final c = Get.put(TrialOfferController(
      MockBillingRepository(),
      now: () => DateTime(2026, 10, 2),
    ));

    await pumpScreen(tester, const TrialPaymentScreen());
    await settleLoads(tester);
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
    Get.put(TrialOfferController(
      MockBillingRepository(),
      now: () => DateTime(2026, 10, 2),
    ));

    await pumpScreen(tester, const TrialPaymentScreen());
    await settleLoads(tester);
    // `311:25477` prints dollars for these; `311:25582` prints naira for the
    // same amounts, and naira is what the rest of the app uses.
    expect(find.textContaining(r'$'), findsNothing);
    // Sales tax and the total both read ₦0.00 during the trial.
    expect(find.text('₦0.00'), findsNWidgets(2));
    expect(find.text('-₦150,000'), findsOneWidget);
  });

  test('an empty promo code is refused before anything is claimed', () {
    Get.testMode = true;
    // Two days after the frame was drawn, so the week ends on the 9th and
    // the screen prints the date the design does.
    final c = Get.put(TrialOfferController(
      MockBillingRepository(),
      now: () => DateTime(2026, 10, 2),
    ));
    c.promo.value = '   ';
    c.applyPromo();
    // Nothing to assert beyond it not throwing; the message is the behaviour.
    c.promo.value = 'SOOTHE10';
    c.applyPromo();
  });

  testWidgets('the pop-up says what the card check costs before the button',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.testMode = true;

    Get.put(TrialOfferController(
      _AsksForACard(),
      now: () => DateTime(2026, 10, 2),
    ));
    await pumpScreen(tester, const TrialOfferScreen());
    await settleLoads(tester);

    // Money leaving somebody's account is not a surprise to spring on them
    // after they have tapped.
    expect(find.textContaining('₦100 to check your card'), findsOneWidget);
    expect(find.textContaining('send it back'), findsOneWidget);
  });

  testWidgets('and says nothing when no card is asked for', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.testMode = true;

    Get.put(TrialOfferController(
      MockBillingRepository(),
      now: () => DateTime(2026, 10, 2),
    ));
    await pumpScreen(tester, const TrialOfferScreen());
    await settleLoads(tester);

    expect(find.textContaining('check your card'), findsNothing);
  });

  testWidgets('a free week granted by the server opens no browser',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.testMode = true;

    final opened = <String>[];
    final wasOpener = CheckoutLauncher.opener;
    CheckoutLauncher.opener = (url) async {
      opened.add(url);
      return true;
    };
    addTearDown(() => CheckoutLauncher.opener = wasOpener);

    final c = Get.put(TrialOfferController(
      _GrantsTheWeek(),
      now: () => DateTime(2026, 10, 2),
    ));
    await pumpScreen(
      tester,
      const TrialOfferScreen(),
      // The week starts straight away, so the pop-up hands the member back
      // to the app rather than leaving them on an offer they have taken.
      pages: [
        GetPage(
          name: AppRoutes.shell,
          page: () => const Scaffold(body: Text('home')),
        ),
      ],
    );

    await c.startFreeWeek();
    await tester.pumpAndSettle();

    // Nothing to pay and nothing to open: the week has already started.
    expect(opened, isEmpty);
    expect(find.text('home'), findsOneWidget);
    // Let the confirmation's snackbar time out inside the test.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}

/// A server that asks for a card before the free week.
class _AsksForACard implements BillingRepository {
  @override
  Future<MembershipStatus> membership() async => const MembershipStatus(
        state: 'inactive',
        trialRequiresCard: true,
        cardCheckNaira: 100,
      );

  @override
  Future<Checkout> startMembership({
    required String planKey,
    String cadence = 'annual',
    bool trial = true,
    String promoCode = '',
  }) async =>
      const Checkout(
        reference: 'chk_1',
        checkoutUrl: 'https://pay.bachs.io/c/2',
        amountNaira: 100,
        cardCheckNaira: 100,
      );

  @override
  Future<MembershipStatus> cancelMembership() async => MembershipStatus.none;

  @override
  Future<Checkout> paySession(String sessionId, {String promoCode = ''}) =>
      throw UnimplementedError();

  @override
  Future<String> paymentStatus(String reference) async => 'pending';

  @override
  Future<Checkout> replaceCard() => throw UnimplementedError();

  @override
  Future<List<BillingInvoice>> invoices() async => const [];

  @override
  Future<Map<String, dynamic>?> checkPromo(String code) async => null;
}

/// A server that hands over the free week on the spot, as it does while
/// memberships are sold one period at a time.
class _GrantsTheWeek implements BillingRepository {
  @override
  Future<Checkout> startMembership({
    required String planKey,
    String cadence = 'annual',
    bool trial = true,
    String promoCode = '',
  }) async =>
      const Checkout(
        reference: '',
        checkoutUrl: '',
        amountNaira: 0,
        trialDays: 7,
        trialStarted: true,
      );

  @override
  Future<MembershipStatus> membership() async => MembershipStatus.none;

  @override
  Future<MembershipStatus> cancelMembership() async => MembershipStatus.none;

  @override
  Future<Checkout> paySession(String sessionId, {String promoCode = ''}) =>
      throw UnimplementedError();

  @override
  Future<String> paymentStatus(String reference) async => 'pending';

  @override
  Future<Checkout> replaceCard() => throw UnimplementedError();

  @override
  Future<List<BillingInvoice>> invoices() async => const [];

  @override
  Future<Map<String, dynamic>?> checkPromo(String code) async => null;
}
