import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/app_export.dart';
import 'package:soothifyafrica/app/core/utils/checkout_launcher.dart';
import 'package:soothifyafrica/app/data/models/checkout.dart';
import 'package:soothifyafrica/app/data/models/passport_tier.dart';
import 'package:soothifyafrica/app/data/repositories/mock_billing_repository.dart';
import 'package:soothifyafrica/app/modules/user/checkout/checkout_webview_screen.dart'
    show CheckoutOutcome;
import 'package:soothifyafrica/app/modules/user/passport/controller/passport_controller.dart';
import 'package:soothifyafrica/app/modules/user/passport/passport_tiers_screen.dart';

import 'helpers.dart';

/// Soothify Passport — Figma `4958:26661`.
///
/// The Plans card collected an email for a waitlist. It sells now: three
/// tiers, each going to its own checkout at Bachs.
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
  });
  // The launcher is a static seam; put it back so one test's stub does not
  // leak into the next file's.
  final realPresenter = CheckoutLauncher.presenter;
  tearDown(() {
    CheckoutLauncher.presenter = realPresenter;
    Get.reset();
  });

  group('the frame’s three tiers', () {
    test('are the copy the design writes, verbatim', () {
      expect(PassportTier.all, hasLength(3));
      final [starter, habit, pro] = PassportTier.all;

      expect(starter.name, 'Starter Flow');
      expect(starter.priceLabel, '₦90,000 / month');
      expect(starter.allowance, '6 Classes Total');
      expect(starter.reformerLimit, 'Max 2 Reformer sessions included');
      expect(starter.emphasised, isFalse);

      // The middle card is the filled one — emphasis, not selection.
      expect(habit.name, 'Habit Builder');
      expect(habit.priceNaira, 125000);
      expect(habit.emphasised, isTrue);

      expect(pro.name, 'Pro Flow');
      expect(pro.priceNaira, 195000);
      expect(pro.emphasised, isFalse);
    });

    test('each button names its own tier', () {
      expect(PassportTier.all.map((t) => t.action), [
        'Select Starter Flow',
        'Select Habit Builder',
        'Select Pro Flow',
      ]);
    });
  });

  testWidgets('the screen draws all three, with their prices',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put(PassportController(MockBillingRepository()));

    await pumpScreen(tester, const PassportTiersScreen());

    expect(find.text('Soothify Passport'), findsOneWidget);
    expect(find.text('Find Your Rhythm'), findsOneWidget);

    // The page is 1548 tall against an 844 viewport, so the third card is
    // below the fold — the frame means it to be scrolled to.
    for (final tier in PassportTier.all) {
      await tester.dragUntilVisible(
        find.text(tier.name),
        find.byType(ListView),
        Offset(0, -200.v),
      );
      expect(find.text(tier.name), findsOneWidget);
      expect(find.text(tier.priceLabel), findsOneWidget);
      expect(find.text(tier.level), findsOneWidget);
      expect(find.text(tier.action), findsOneWidget);
    }
  });

  for (final (shade, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('passport tiers, $shade', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.put(PassportController(MockBillingRepository()));

      await pumpScreen(tester, const PassportTiersScreen(),
          brightness: brightness);

      await expectLater(find.byType(PassportTiersScreen),
          matchesGoldenFile('goldens/passport_tiers_$shade.png'));
    });
  }

  test('choosing a tier starts that tier’s checkout', () async {
    final billing = _RecordingBilling();
    final c = PassportController(billing);
    CheckoutLauncher.presenter = (_, _) async => CheckoutOutcome.returned;

    await c.choose(PassportTier.all[1]);

    expect(billing.started, [('passport-habit', 'monthly', false)]);
    expect(c.busy.value, isFalse);
  });

  test('a checkout with no product behind it charges nothing', () async {
    final billing = _RecordingBilling(url: '');
    final c = PassportController(billing);
    var presented = false;
    CheckoutLauncher.presenter = (_, _) async {
      presented = true;
      return CheckoutOutcome.returned;
    };

    await c.choose(PassportTier.all.first);

    expect(presented, isFalse,
        reason: 'nothing to open, so nothing is opened');
    expect(c.chosen.value, isNull);
  });
}

class _RecordingBilling extends MockBillingRepository {
  _RecordingBilling({this.url = 'https://pay.bachs.test/x'});

  final String url;
  final List<(String, String, bool)> started = [];

  @override
  Future<Checkout> startMembership({
    required String planKey,
    String cadence = 'annual',
    bool trial = true,
    String promoCode = '',
  }) async {
    started.add((planKey, cadence, trial));
    return Checkout(
      reference: 'ref-1',
      checkoutUrl: url,
      amountNaira: 125000,
    );
  }

  @override
  Future<String> paymentStatus(String reference) async => 'paid';
}
