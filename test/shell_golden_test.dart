import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_subscription_repository.dart';
import 'package:soothifyafrica/app/data/repositories/subscription_repository.dart';
import 'package:soothifyafrica/app/data/repositories/local_profile_repository.dart';
import 'package:soothifyafrica/app/data/repositories/profile_repository.dart';
import 'package:soothifyafrica/app/data/services/theme_service.dart';
import 'package:soothifyafrica/app/modules/user/shell/binding/shell_binding.dart';
import 'package:soothifyafrica/app/modules/user/shell/shell_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/shell_golden_test.dart
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
    testWidgets('shell with the bottom nav, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();

      Get.put(await ThemeService().init());
      Get.put<ContentRepository>(MockContentRepository());
      Get.put<ProfileRepository>(LocalProfileRepository());
      Get.put<SubscriptionRepository>(MockSubscriptionRepository());
      // Through the real binding rather than by hand: the shell's IndexedStack
      // builds every tab at once, so each new tab's controller has to be
      // registered here too, and a hand-written list silently drifts out of
      // date the moment a tab is added.
      ShellBinding().dependencies();

      await pumpScreen(tester, const ShellScreen(), brightness: brightness);
      // Let every tab's mock latency elapse — the IndexedStack builds all
      // five, and Discovery's controller makes two rounds of calls, so 500ms
      // left a timer pending and failed the test after the tree was gone.
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();

      await expectLater(find.byType(ShellScreen),
          matchesGoldenFile('goldens/shell_$name.png'));
    });
  }
}
