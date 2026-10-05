import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/app_tab.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_subscription_repository.dart';
import 'package:soothifyafrica/app/data/repositories/subscription_repository.dart';
import 'package:soothifyafrica/app/data/repositories/local_profile_repository.dart';
import 'package:soothifyafrica/app/data/repositories/profile_repository.dart';
import 'package:soothifyafrica/app/data/services/session_service.dart';
import 'package:soothifyafrica/app/data/services/theme_service.dart';
import 'package:soothifyafrica/app/modules/user/shell/binding/shell_binding.dart';
import 'package:soothifyafrica/app/modules/user/shell/tabs/home_tab_controller.dart';
import 'package:soothifyafrica/app/modules/user/shell/shell_screen.dart';
import 'package:soothifyafrica/app/modules/user/shell/widgets/app_bottom_nav.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/shell_golden_test.dart
const _art = [
  'assets/images/home/ai_assist.png',
  'assets/images/home/avatar.png',
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
    testWidgets('shell with the bottom nav, $name', (tester) async {
      useDesignFrame(tester);
      disableMotion(tester);
      await loadAppFonts();

      Get.put(await ThemeService().init());
      Get.put<ContentRepository>(MockContentRepository());
      // The header branches on guest vs signed in.
      Get.put(await SessionService().init());
      Get.put<ProfileRepository>(LocalProfileRepository());
      Get.put<SubscriptionRepository>(MockSubscriptionRepository());
      // Through the real binding rather than by hand: the shell's IndexedStack
      // builds every tab at once, so each new tab's controller has to be
      // registered here too, and a hand-written list silently drifts out of
      // date the moment a tab is added.
      ShellBinding().dependencies();
      // ...then pin Home's clock. The greeting is time of day, so a golden
      // recorded in the morning fails in the afternoon.
      //
      // The delete matters: the binding has already registered a lazy
      // HomeTabController, and putting another over it did not take — the tab
      // kept finding the binding's, on the real clock. That made this test
      // pass only before noon, which is why it went unnoticed.
      Get.delete<HomeTabController>();
      Get.put(HomeTabController(Get.find<ContentRepository>(),
          now: fixedMorning));

      await pumpScreen(tester, const ShellScreen(), brightness: brightness);
      // Let every tab's mock latency elapse — the IndexedStack builds all
      // five, and Discovery's controller makes two rounds of calls, so 500ms
      // left a timer pending and failed the test after the tree was gone.
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
      await precacheAll(tester, find.byType(ShellScreen), _art);

      // The clock is pinned to 09:00, so this must be the morning greeting.
      // Without the assertion a broken pin only shows up as a golden that
      // passes in the morning and fails after lunch.
      expect(find.text('Good morning'), findsOneWidget);

      await expectLater(find.byType(ShellScreen),
          matchesGoldenFile('goldens/shell_$name.png'));
    });
  }

  testWidgets('the nav bar clears the system navigation buttons',
      (tester) async {
    useDesignFrame(tester);
    disableMotion(tester);
    await loadAppFonts();
    // A phone with on-screen navigation buttons: 48 of system bar under the
    // app. The design frame alone has none, which is why this never showed.
    tester.view.viewPadding = const FakeViewPadding(bottom: 48 * 3);
    tester.view.padding = const FakeViewPadding(bottom: 48 * 3);
    addTearDown(() {
      tester.view
        ..resetViewPadding()
        ..resetPadding();
    });

    Get.put(await ThemeService().init());
    Get.put<ContentRepository>(MockContentRepository());
    Get.put(await SessionService().init());
    Get.put<ProfileRepository>(LocalProfileRepository());
    Get.put<SubscriptionRepository>(MockSubscriptionRepository());
    ShellBinding().dependencies();
    Get.delete<HomeTabController>();
    Get.put(HomeTabController(Get.find<ContentRepository>(),
        now: fixedMorning));

    await pumpScreen(tester, const ShellScreen());
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    final bar = tester.getRect(find.byType(AppBottomNav));
    // The whole bar is 74 plus the system inset — the inset is padding under
    // it, not a bite out of it. It used to be a flat 74 with a SafeArea
    // inside, so the tabs were squashed into 26 and sat behind the buttons.
    expect(bar.height, closeTo(74 + 48, 0.5));

    // And every tab sits above the system bar.
    final floor = bar.bottom - 48;
    for (final tab in AppTab.values) {
      expect(
        tester.getRect(find.text(tab.label).last).bottom,
        lessThan(floor),
        reason: '${tab.label} must not sit under the navigation buttons',
      );
    }
  });
}