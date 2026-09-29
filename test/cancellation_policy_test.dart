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
    expect(find.text('Cancellation Policy'), findsOneWidget);
    // The frame's label reads "Go Bavk".
    expect(find.text('Go Back'), findsOneWidget);
    expect(find.text('Go Bavk'), findsNothing);
  });

  testWidgets('the policy is the frame’s own wording', (tester) async {
    await mount(tester);
    // `280:26738` carries all 193 characters of this. An earlier reading had
    // it stopping at "...for a full refund if you" — that was the spec
    // printer clipping at 48 characters, not the design.
    expect(CancellationPolicyScreen.body, isNot(endsWith('if you')));
    expect(find.textContaining('at least 24 hours before'), findsOneWidget);
    expect(find.textContaining('not eligible for a refund'), findsOneWidget);
  });
}
