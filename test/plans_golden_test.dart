import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';
import 'package:soothifyafrica/app/data/models/plan_tier.dart';
import 'package:soothifyafrica/app/data/repositories/mock_subscription_repository.dart';
import 'package:soothifyafrica/app/modules/user/plans/controller/plans_tab_controller.dart';
import 'package:soothifyafrica/app/modules/user/plans/plans_tab.dart';
import 'package:soothifyafrica/app/modules/user/spaces/widgets/passport_sheet.dart';

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

  testWidgets('the three cards the designer redrew', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put(PlansTabController(MockSubscriptionRepository()));

    await pumpScreen(tester, const PlansTab());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Soothify Core'), findsOneWidget);
    expect(find.text('Soothify Passport'), findsOneWidget);
    expect(find.text('Soothify Corporate Wellness'), findsOneWidget);

    // Only Core carries a price; the other two carry a link instead.
    expect(find.text('₦15,000'), findsOneWidget);
    expect(find.text('/One time access'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Start 7-Day Free Trial'),
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    expect(find.text(PlanAction.waitlist.label), findsOneWidget);
    expect(find.text(PlanAction.corporate.label), findsOneWidget);
    expect(find.text('Start 7-Day Free Trial'), findsOneWidget);
    // The screen no longer gates on a selection, so there is no Continue.
    expect(find.text('Continue'), findsNothing);
  });

  testWidgets('the Passport card opens the waitlist sheet', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    // The sheet reads a previously-left address on mount.
    await PrefUtils().init();
    Get.put(PlansTabController(MockSubscriptionRepository()));

    await pumpScreen(tester, const PlansTab());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text(PlanAction.waitlist.label),
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(PlanAction.waitlist.label));
    await tester.pumpAndSettle();

    // The same waitlist the Spaces flow opens, not a second one.
    expect(find.text(PassportSheet.heading), findsOneWidget);
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

  testWidgets('a card takes its accent border only once it is tapped',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = Get.put(PlansTabController(MockSubscriptionRepository()));

    await pumpScreen(tester, const PlansTab());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    Color rimOf(String name) {
      final box = tester.widget<Container>(
        find
            .ancestor(of: find.text(name), matching: find.byType(Container))
            .first,
      );
      return ((box.decoration! as BoxDecoration).border! as Border).top.color;
    }

    // Nothing is chosen yet, so every card rests on the 4% hairline.
    expect(c.chosen.value, isNull);
    for (final name in const [
      'Soothify Core',
      'Soothify Passport',
      'Soothify Corporate Wellness',
    ]) {
      expect(rimOf(name), appTheme.cardRim);
    }

    await tester.tap(find.text('Soothify Core'));
    await tester.pumpAndSettle();
    expect(rimOf('Soothify Core'), appTheme.actionFill);
    // And only that one.
    expect(rimOf('Soothify Passport'), appTheme.cardRim);

    // The filled card takes the orange, which is the only accent that shows
    // against its own blue.
    await tester.tap(find.text('Soothify Passport'));
    await tester.pumpAndSettle();
    expect(rimOf('Soothify Passport'), appTheme.planEmphasisOutline);
    expect(rimOf('Soothify Core'), appTheme.cardRim);
  });
}