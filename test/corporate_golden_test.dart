import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/modules/user/corporate/controller/corporate_controller.dart';
import 'package:soothifyafrica/app/modules/user/corporate/corporate_form_screen.dart';
import 'package:soothifyafrica/app/modules/user/corporate/corporate_success_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/corporate_golden_test.dart
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
    testWidgets('corporate form, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.put(CorporateController());

      await pumpScreen(tester, const CorporateFormScreen(),
          brightness: brightness);
      await expectLater(find.byType(CorporateFormScreen),
          matchesGoldenFile('goldens/corporate_form_$name.png'));
    });

    testWidgets('corporate success, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.put(CorporateController());

      await pumpScreen(tester, const CorporateSuccessScreen(),
          brightness: brightness);
      await expectLater(find.byType(CorporateSuccessScreen),
          matchesGoldenFile('goldens/corporate_success_$name.png'));
    });
  }

  testWidgets('every field the frame draws, with its placeholder',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put(CorporateController());

    await pumpScreen(tester, const CorporateFormScreen());

    for (final field in CorporateField.values) {
      await tester.dragUntilVisible(
        find.text(field.label),
        find.byType(Scrollable).first,
        const Offset(0, -120),
      );
      expect(find.text(field.label), findsOneWidget);
      // The frame's sample text is a placeholder, never a value.
      expect(find.text(field.hint), findsOneWidget);
    }
  });

  test('an empty form names what is missing instead of submitting', () {
    Get.testMode = true;
    final c = Get.put(CorporateController());

    c.submit();
    expect(c.missing, CorporateField.values.where((f) => f.required).toSet());

    for (final f in CorporateField.values.where((f) => f.required)) {
      c.fields[f]!.text = 'x';
    }
    // Typing clears the mark on its own field.
    c.onChanged(CorporateField.company, 'x');
    expect(c.missing.contains(CorporateField.company), isFalse);

    c.submit();
    expect(c.missing, isEmpty);
  });
}
