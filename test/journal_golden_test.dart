import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/modules/user/journal/controller/journal_controller.dart';
import 'package:soothifyafrica/app/modules/user/journal/journal_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/journal_golden_test.dart
const _art = [
  'assets/images/journal/empty.png',
  'assets/images/journal/compose_fab.png',
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
    testWidgets('journal empty state, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.put(JournalController());

      await pumpScreen(tester, const JournalScreen(), brightness: brightness);

      await precacheAll(tester, find.byType(JournalScreen), _art);

      await expectLater(find.byType(JournalScreen),
          matchesGoldenFile('goldens/journal_$name.png'));
    });
  }
}
