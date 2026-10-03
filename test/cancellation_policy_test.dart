import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/modules/user/payment/cancellation_policy_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/cancellation_policy_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<void> mount(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    await pumpScreen(tester, const CancellationPolicyScreen(),
        brightness: brightness);
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('cancellation policy, $name', (tester) async {
      await mount(tester, brightness: brightness);
      await expectLater(find.byType(CancellationPolicyScreen),
          matchesGoldenFile('goldens/cancellation_policy_$name.png'));
    });
  }

  testWidgets('it carries the section header and the frame’s action',
      (tester) async {
    await mount(tester);
    // The whole expert section titles itself "Schedule".
    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('Cancellation & Refund Policy'), findsOneWidget);
    // The frame's label reads "Go Bavk".
    expect(find.text('Go Back'), findsOneWidget);
    expect(find.text('Go Bavk'), findsNothing);
  });

  testWidgets('it prints the policy the designer supplied', (tester) async {
    await mount(tester);

    expect(find.text(CancellationPolicyScreen.effectiveDate), findsOneWidget);
    for (final section in CancellationPolicyScreen.sections) {
      expect(find.text(section.heading), findsOneWidget,
          reason: section.heading);
    }
    // The frame's two summary sentences are section 2 stated in full; the
    // 24-hour rule has to survive the swap in both directions.
    expect(find.textContaining('more than 24 hours prior'), findsOneWidget);
    expect(find.textContaining('strictly non-refundable'), findsOneWidget);
  });
}
