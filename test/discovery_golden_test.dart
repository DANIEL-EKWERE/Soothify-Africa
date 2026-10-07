import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_subscription_repository.dart';
import 'package:soothifyafrica/app/modules/user/discovery/controller/discovery_tab_controller.dart';
import 'package:soothifyafrica/app/modules/user/discovery/discovery_tab.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/discovery_golden_test.dart
// PNGs only: precacheImage decodes raster data, and handing it an SVG
// fails with "Invalid image data". flutter_svg loads those itself.
const _covers = [
  'assets/images/content/cover_a.png',
  'assets/images/content/cover_b.png',
  'assets/images/content/cover_c.png',
  'assets/images/content/unshakeable.png',
  'assets/images/content/hope_in_the_shadows.png',
  'assets/images/content/breaking_bad_habit.png',
  'assets/images/content/daily_focus.png',
  'assets/images/content/breath_work.png',
  'assets/images/content/mindfulness.png',
];

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
    testWidgets('discovery, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.put<ContentRepository>(MockContentRepository());
      Get.put(DiscoveryTabController(
        Get.find<ContentRepository>(),
        MockSubscriptionRepository(),
      ));

      await pumpScreen(tester, const DiscoveryTab(), brightness: brightness);
      // The mocks answer after a deliberate delay, which pumpAndSettle alone
      // does not advance.
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();
      // Asset images resolve asynchronously; without this the covers render
      // blank and the golden records placeholders instead of the art.
      await precacheAll(tester, find.byType(DiscoveryTab), _covers);

      await expectLater(find.byType(DiscoveryTab),
          matchesGoldenFile('goldens/discovery_$name.png'));
    });
  }

  testWidgets('searching swaps the tab for the search surface', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final controller = DiscoveryTabController(
      MockContentRepository(),
      MockSubscriptionRepository(),
    );
    Get.put(controller);

    await pumpScreen(tester, const DiscoveryTab());
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    await tester.tap(find.text('What can we help you find?'));
    await tester.pumpAndSettle();

    // The shelves give way to the field.
    expect(find.text('Recent'), findsNothing);
    expect(find.text('Spaces Around Me'), findsNothing);
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Voice over');
    // One frame: the spinner is up before the request has been made.
    await tester.pump();
    expect(find.textContaining('Searching for'), findsOneWidget);
    expect(find.text('Searching for \u201Cvoice over\u201D...'), findsOneWidget);

    // Past the debounce and the mock's latency.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
    expect(find.textContaining('Searching for'), findsNothing);
    expect(controller.searched.value, isTrue);

    // Back leaves the search and restores the tab.
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    expect(find.text('Recent'), findsOneWidget);
    expect(controller.query.value, isEmpty);
    // Clearing the field rearms the debounce; let it fire, or the binding
    // fails the test for a timer outliving the tree.
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('a query that matches nothing says so', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put(DiscoveryTabController(
      MockContentRepository(),
      MockSubscriptionRepository(),
    ));

    await pumpScreen(tester, const DiscoveryTab());
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    await tester.tap(find.text('What can we help you find?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzzzzz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.text('No results found'), findsOneWidget);
  });

  testWidgets('the card ships its first tier selected', (tester) async {
    useDesignFrame(tester);
    // Without the real font the fallback renders far wider and every row
    // reports a spurious overflow, which reads as a layout bug that is not one.
    await loadAppFonts();
    final controller = DiscoveryTabController(
      MockContentRepository(),
      MockSubscriptionRepository(),
    );
    Get.put(controller);

    await pumpScreen(tester, const DiscoveryTab());
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(controller.selectedPlanId.value, 'core');

    // The subscription card sits below the fold on an 844-tall frame, so the
    // row has to be brought into view before it can be tapped.
    // The card sells the same three tiers Plans does, by the same names.
    await tester.ensureVisible(findSoothify('Soothify Passport'));
    await tester.pumpAndSettle();
    await tester.tap(findSoothify('Soothify Passport'));
    await tester.pumpAndSettle();
    expect(controller.selectedPlanId.value, 'passport');
    expect(find.text('One time'), findsNothing);
  });
}
