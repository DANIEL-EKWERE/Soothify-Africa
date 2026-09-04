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

  testWidgets('the design ships One time selected', (tester) async {
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

    expect(controller.selectedPlanId.value, 'one-time');

    // The subscription card sits below the fold on an 844-tall frame, so the
    // row has to be brought into view before it can be tapped.
    await tester.ensureVisible(find.text('Pro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pro'));
    await tester.pumpAndSettle();
    expect(controller.selectedPlanId.value, 'pro');
  });
}
