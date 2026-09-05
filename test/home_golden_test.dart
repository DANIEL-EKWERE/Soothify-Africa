import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/data/services/session_service.dart';
import 'package:soothifyafrica/app/data/services/theme_service.dart';
import 'package:soothifyafrica/app/modules/user/shell/tabs/home_tab.dart';
import 'package:soothifyafrica/app/modules/user/shell/tabs/home_tab_controller.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/home_golden_test.dart
// PNGs only: precacheImage decodes raster data, and handing it an SVG
// fails with "Invalid image data". flutter_svg loads those itself.
const _covers = [
  'assets/images/home/ai_assist.png',
  'assets/images/home/avatar.png',
  'assets/images/content/unshakeable.png',
  'assets/images/content/hope_in_the_shadows.png',
  'assets/images/content/breaking_bad_habit.png',
  'assets/images/content/daily_focus.png',
  'assets/images/content/breath_work.png',
  'assets/images/content/mindfulness.png',
  'assets/images/explore/meditation.png',
  'assets/images/explore/schedule.png',
  'assets/images/explore/balance.png',
  'assets/images/home/mood_checker_icon.png',
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
    testWidgets('home, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();

      Get.put(await ThemeService().init());
      Get.put<ContentRepository>(MockContentRepository());
      // The header branches on guest vs signed in.
      Get.put(await SessionService().init());
      Get.put(HomeTabController(Get.find<ContentRepository>()));

      await pumpScreen(tester, const HomeTab(), brightness: brightness);
      // The mock repository answers after a deliberate delay. pumpAndSettle
      // does not advance a plain Future.delayed, so without this the lists are
      // still empty when the frame is captured — and the timer outlives the
      // test.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      await precacheAll(tester, find.byType(HomeTab), _covers);

      await expectLater(
          find.byType(HomeTab), matchesGoldenFile('goldens/home_$name.png'));
    });
  }
}
