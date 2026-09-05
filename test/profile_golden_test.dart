import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/checkin_kind.dart';
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

  testWidgets('each pill switches to its own section', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final controller = ProfileTabController(_FakeProfileRepository());
    Get.put(controller);

    await pumpScreen(tester, const ProfileTab());
    expect(controller.section.value, ProfileSection.dashboard);
    expect(find.text('My stats'), findsOneWidget);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(controller.section.value, ProfileSection.history);
    expect(find.text('My Calendar'), findsOneWidget);

    await tester.tap(find.text('Check-Ins'));
    await tester.pumpAndSettle();
    expect(controller.section.value, ProfileSection.checkIns);
    // All four kinds the design lists.
    for (final kind in CheckinKind.values) {
      expect(find.text(kind.title), findsOneWidget,
          reason: '${kind.title} is missing');
    }
  });

  for (final (name, section) in [
    ('history', ProfileSection.history),
    ('checkins', ProfileSection.checkIns),
  ]) {
    testWidgets('profile $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.put(ProfileTabController(_FakeProfileRepository())
        ..section.value = section);

      await pumpScreen(tester, const ProfileTab());

      await expectLater(find.byType(ProfileTab),
          matchesGoldenFile('goldens/profile_$name.png'));
    });
  }
}
