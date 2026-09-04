import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/plan_tier.dart';
import 'package:soothifyafrica/app/data/repositories/mock_subscription_repository.dart';
import 'package:soothifyafrica/app/modules/user/plans/controller/plans_tab_controller.dart';
import 'package:soothifyafrica/app/modules/user/plans/plans_tab.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/plans_golden_test.dart
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
    testWidgets('plans, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.put(PlansTabController(MockSubscriptionRepository()));

      await pumpScreen(tester, const PlansTab(), brightness: brightness);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      await expectLater(
          find.byType(PlansTab), matchesGoldenFile('goldens/plans_$name.png'));
    });
  }

  testWidgets('Continue stays blocked until a tier is picked', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final controller = PlansTabController(MockSubscriptionRepository());
    Get.put(controller);

    await pumpScreen(tester, const PlansTab());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // The frame draws the button at 45% with nothing selected, so an empty
    // selection is the design's own starting state rather than an oversight.
    expect(controller.canContinue, isFalse);

    await tester.ensureVisible(find.text('One-Off Plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('One-Off Plan'));
    await tester.pumpAndSettle();

    expect(controller.selectedTierId.value, 'one-off');
    expect(controller.canContinue, isTrue);
  });

  testWidgets('switching period reloads the tiers', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final controller = PlansTabController(MockSubscriptionRepository());
    Get.put(controller);

    await pumpScreen(tester, const PlansTab());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(controller.period.value, BillingPeriod.monthly);

    await tester.tap(find.text('Annual'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(controller.period.value, BillingPeriod.annual);
    expect(controller.tiers, isNotEmpty);
  });
}
