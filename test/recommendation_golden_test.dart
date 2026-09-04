import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/modules/user/recommendation/controller/recommendation_controller.dart';
import 'package:soothifyafrica/app/modules/user/recommendation/recommendation_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/recommendation_golden_test.dart
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
    testWidgets('recommendation, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();

      Get.put<ContentRepository>(MockContentRepository());
      Get.put(RecommendationController(Get.find<ContentRepository>()));

      await pumpScreen(tester, const RecommendationScreen(),
          brightness: brightness);
      // The mock answers after a deliberate delay.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      await expectLater(find.byType(RecommendationScreen),
          matchesGoldenFile('goldens/recommendation_$name.png'));
    });
  }
}
