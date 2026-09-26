import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/subscription_offer.dart';
import 'package:soothifyafrica/app/modules/user/subscription/controller/subscription_offer_controller.dart';
import 'package:soothifyafrica/app/modules/user/subscription/subscription_offer_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/subscription_offer_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<SubscriptionOfferController> mount(
    WidgetTester tester,
    SubscriptionOffer offer, {
    Brightness brightness = Brightness.light,
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = Get.put(SubscriptionOfferController(offer));
    await pumpScreen(tester, const SubscriptionOfferScreen(),
        brightness: brightness);
    return c;
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    for (final offer in SubscriptionOffer.values) {
      testWidgets('subscription ${offer.name}, $name', (tester) async {
        await mount(tester, offer, brightness: brightness);

        await expectLater(
          find.byType(SubscriptionOfferScreen),
          matchesGoldenFile('goldens/subscription_${offer.name}_$name.png'),
        );
      });
    }
  }

  testWidgets('the trial picks a period; the discounted year does not',
      (tester) async {
    final c = await mount(tester, SubscriptionOffer.trial);
    expect(c.period.value, OfferPeriod.annual,
        reason: 'the frame ticks the annual card');
    expect(find.textContaining('Annual'), findsOneWidget);
    expect(find.textContaining('Monthly'), findsOneWidget);
    expect(find.text('Start free trial'), findsOneWidget);

    c.choose(OfferPeriod.monthly);
    await tester.pumpAndSettle();
    expect(c.period.value, OfferPeriod.monthly);

    Get.reset();
    await mount(tester, SubscriptionOffer.discountedYear);
    expect(find.textContaining('Annual'), findsNothing);
    expect(find.text('Claim 20% off'), findsOneWidget);
  });

  testWidgets('both frames share the blurb, the table and the footer',
      (tester) async {
    for (final offer in SubscriptionOffer.values) {
      await mount(tester, offer);
      expect(find.textContaining('unlimited access to every guided session'),
          findsOneWidget);
      expect(find.text('Feature'), findsOneWidget);
      expect(find.text('Free'), findsOneWidget);
      expect(find.text('Premium'), findsOneWidget);
      expect(find.text('Not sure? Learn about our free year'), findsOneWidget);
      expect(find.text('Restore purchase'), findsOneWidget);
      Get.reset();
    }
  });

  group('the comparison table', () {
    test('has five rows, only the first of which is free', () {
      // Read off the tick and cross marks in the frame, not assumed.
      expect(SubscriptionOffer.comparison, hasLength(5));
      expect(SubscriptionOffer.comparison.first.free, isTrue);
      for (final row in SubscriptionOffer.comparison.skip(1)) {
        expect(row.free, isFalse, reason: '${row.feature} is premium-only');
      }
    });

    test('names the sections by their current names', () {
      final features =
          SubscriptionOffer.comparison.map((r) => r.feature).join(' ');
      expect(features, contains('Pilates & Core'));
      expect(features, contains('Stretch & Restore'));
    });
  });

  testWidgets('one screen serves both frames', (tester) async {
    for (final offer in SubscriptionOffer.values) {
      final c = await mount(tester, offer);
      expect(c.offer, offer);
      expect(find.text(offer.action), findsOneWidget);
      Get.reset();
    }
  });
}
