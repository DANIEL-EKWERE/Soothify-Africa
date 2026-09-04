import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/modules/user/journal/controller/journal_compose_controller.dart';
import 'package:soothifyafrica/app/modules/user/journal/journal_compose_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/journal_compose_golden_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  // Pinned: the header shows the date and time, so a golden built from the
  // real clock fails on the next run.
  DateTime now() => DateTime(2024, 7, 15, 9, 41);

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('journal composer, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.put(JournalComposeController(now: now));

      await pumpScreen(tester, const JournalComposeScreen(),
          brightness: brightness);

      await expectLater(find.byType(JournalComposeScreen),
          matchesGoldenFile('goldens/journal_compose_$name.png'));
    });
  }
}
