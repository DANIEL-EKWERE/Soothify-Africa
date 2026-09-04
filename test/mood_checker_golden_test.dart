import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';

import 'package:soothifyafrica/app/data/models/mood.dart';
import 'package:soothifyafrica/app/data/repositories/local_mood_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mood_repository.dart';
import 'package:soothifyafrica/app/modules/user/mood_checker/controller/mood_checker_controller.dart';
import 'package:soothifyafrica/app/modules/user/mood_checker/mood_checker_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/mood_checker_golden_test.dart
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
    testWidgets('mood checker, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();

      Get.put<MoodRepository>(LocalMoodRepository());
      Get.put(MoodCheckerController(Get.find<MoodRepository>()));

      await pumpScreen(tester, const MoodCheckerScreen(),
          brightness: brightness);
      await precacheAll(
        tester,
        find.byType(MoodCheckerScreen),
        Mood.values.map((m) => m.assetPath),
      );

      await expectLater(find.byType(MoodCheckerScreen),
          matchesGoldenFile('goldens/mood_checker_$name.png'));
    });
  }
}
