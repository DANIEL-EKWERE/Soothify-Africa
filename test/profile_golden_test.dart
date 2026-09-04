import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/profile_stats.dart';
import 'package:soothifyafrica/app/data/repositories/profile_repository.dart';
import 'package:soothifyafrica/app/modules/user/profile/controller/profile_tab_controller.dart';
import 'package:soothifyafrica/app/modules/user/profile/profile_tab.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/profile_golden_test.dart
class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<ProfileStats> getStats() async => ProfileStats.empty;
}

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
    testWidgets('profile dashboard, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.put(ProfileTabController(_FakeProfileRepository()));

      await pumpScreen(tester, const ProfileTab(), brightness: brightness);

      await expectLater(find.byType(ProfileTab),
          matchesGoldenFile('goldens/profile_$name.png'));
    });
  }

  testWidgets('selecting an unbuilt section leaves Dashboard showing',
      (tester) async {
    useDesignFrame(tester);
    final controller = ProfileTabController(_FakeProfileRepository());
    Get.put(controller);

    await pumpScreen(tester, const ProfileTab());

    await tester.tap(find.text('History'));
    await tester.pump();

    // The pill must not latch onto a section with no screen behind it.
    expect(controller.section.value, ProfileSection.dashboard);

    // The rejection surfaces through a GetX snackbar, whose animation
    // outlives the tree and fails the test as a leaked Ticker unless it is
    // drained before teardown.
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });
}
