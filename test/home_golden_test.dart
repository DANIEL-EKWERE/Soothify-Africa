import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/data/services/theme_service.dart';
import 'package:soothifyafrica/app/modules/user/shell/tabs/home_tab.dart';
import 'package:soothifyafrica/app/modules/user/shell/tabs/home_tab_controller.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/home_golden_test.dart
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
    testWidgets('home, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();

      Get.put(await ThemeService().init());
      Get.put<ContentRepository>(MockContentRepository());
      Get.put(HomeTabController(Get.find<ContentRepository>()));

      await pumpScreen(tester, const HomeTab(), brightness: brightness);
      // The mock repository answers after a deliberate delay. pumpAndSettle
      // does not advance a plain Future.delayed, so without this the lists are
      // still empty when the frame is captured — and the timer outlives the
      // test.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      await expectLater(
          find.byType(HomeTab), matchesGoldenFile('goldens/home_$name.png'));
    });
  }
}
