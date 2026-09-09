import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/checkin_kind.dart';
import 'package:soothifyafrica/app/data/models/profile_stats.dart';
import 'package:soothifyafrica/app/data/models/user_role.dart';
import 'package:soothifyafrica/app/data/repositories/profile_repository.dart';
import 'package:soothifyafrica/app/data/services/session_service.dart';
import 'package:soothifyafrica/app/modules/user/profile/controller/profile_tab_controller.dart';
import 'package:soothifyafrica/app/modules/user/profile/profile_tab.dart';

import 'package:soothifyafrica/app/theme/theme_helper.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/profile_golden_test.dart
/// Signed in unless a test says otherwise.
class _FakeSession extends SessionService {
  _FakeSession({required bool guest}) {
    role.value = guest ? null : UserRole.user;
  }
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<ProfileStats> getStats() async => ProfileStats.empty;
}

/// PNGs only: precacheImage decodes raster data and rejects an SVG. Without
/// these the profile goldens recorded blank boxes where the stat glyphs and
/// the sign-up card's icons should be — which is how the black-on-blue stat
/// icons went unnoticed.
const _art = [
  'assets/images/profile/stat_meditation.png',
  'assets/images/profile/stat_balance.png',
  'assets/images/profile/signup_clock.png',
  'assets/images/profile/signup_calendar.png',
  'assets/images/profile/signup_mind.png',
  'assets/images/profile/ic_settings_gear.png',
  'assets/images/profile/ic_person.png',
  'assets/images/home/avatar.png',
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
    testWidgets('profile dashboard, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.put(ProfileTabController(_FakeProfileRepository(), _FakeSession(guest: false)));

      await pumpScreen(tester, const ProfileTab(), brightness: brightness);
      await precacheAll(tester, find.byType(ProfileTab), _art);

      await expectLater(find.byType(ProfileTab),
          matchesGoldenFile('goldens/profile_$name.png'));
    });
  }

  testWidgets('each pill switches to its own section', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final controller = ProfileTabController(_FakeProfileRepository(), _FakeSession(guest: false));
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
      Get.put(ProfileTabController(_FakeProfileRepository(), _FakeSession(guest: false))
        ..section.value = section);

      await pumpScreen(tester, const ProfileTab());

      await expectLater(find.byType(ProfileTab),
          matchesGoldenFile('goldens/profile_$name.png'));
    });
  }

  testWidgets('a guest is offered sign-up instead of stats', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put(ProfileTabController(
      _FakeProfileRepository(),
      _FakeSession(guest: true),
    ));

    await pumpScreen(tester, const ProfileTab());

    // No stats, no tabs — none of it means anything without an account.
    expect(find.text('My stats'), findsNothing);
    expect(find.text('Dashboard'), findsNothing);
    expect(find.textContaining('Create an account'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
    // The gear is a guest's way into Settings — the only frame that shows one.
    expect(find.text('Unlock Soothify Pro'), findsOneWidget);

    await precacheAll(tester, find.byType(ProfileTab), _art);
    await expectLater(find.byType(ProfileTab),
        matchesGoldenFile('goldens/profile_unsigned.png'));
  });

  testWidgets('History picks a day in orange, and has no confirm button',
      (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final controller = ProfileTabController(
      _FakeProfileRepository(),
      _FakeSession(guest: false),
    );
    Get.put(controller);

    await pumpScreen(tester, const ProfileTab());
    controller.section.value = ProfileSection.history;
    await tester.pumpAndSettle();

    expect(find.text('My Calendar'), findsOneWidget);
    // The frame has no confirm button under the calendar; an earlier build
    // added a permanently disabled "Select date" that led nowhere.
    expect(find.text('Select date'), findsNothing);

    await tester.tap(find.text('14'));
    await tester.pumpAndSettle();

    expect(controller.selectedDate.value, DateTime(2024, 8, 14));
    // Orange, not the blue every other calendar in the app selects with.
    final filled = tester
        .widgetList<Container>(find.byType(Container))
        .where((c) =>
            (c.decoration as BoxDecoration?)?.color == PrimaryColors.light.daySelected);
    expect(filled, isNotEmpty,
        reason: 'the chosen day should be filled with daySelected');
  });
}
