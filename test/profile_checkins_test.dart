import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/app_export.dart';
import 'package:soothifyafrica/app/data/models/checkin_kind.dart';
import 'package:soothifyafrica/app/data/repositories/local_profile_repository.dart';
import 'package:soothifyafrica/app/data/services/session_service.dart';
import 'package:soothifyafrica/app/modules/user/profile/controller/profile_tab_controller.dart';
import 'package:soothifyafrica/app/modules/user/profile/widgets/profile_checkins.dart';

import 'helpers.dart';

/// The Check-Ins tab — Figma "Profile/mood checkin" (`176:34213`).
///
/// It had no test at all: the goldens on disk were orphans left by a
/// renamed one, so nothing noticed that Breathing's badge was a rectangle
/// among circles.
///
/// Regenerate with:
///   flutter test --update-goldens test/profile_checkins_test.dart
const _badges = [
  'assets/images/checkin/ic_mood.png',
  'assets/images/checkin/ic_journal.png',
  'assets/images/explore/meditation.png',
  'assets/images/explore/balance.png',
  'assets/images/content/breath_work.png',
];

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<void> mount(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final session = await SessionService().init();
    Get.put(ProfileTabController(LocalProfileRepository(), session));
    await pumpScreen(
      tester,
      // Inside a Scaffold: the cards' buttons are InkWells, which need a
      // Material ancestor, and in the app the tab sits in one.
      Scaffold(
        backgroundColor: appTheme.background,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(22.h),
          child: const ProfileCheckins(),
        ),
      ),
      brightness: brightness,
    );
    await tester.pumpAndSettle();
    await precacheAll(tester, find.byType(ProfileCheckins), _badges);
  }

  for (final (shade, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('check-ins, $shade', (tester) async {
      await mount(tester, brightness: brightness);

      await expectLater(find.byType(ProfileCheckins),
          matchesGoldenFile('goldens/profile_checkins_$shade.png'));
    });
  }

  testWidgets('Breathing’s badge is round too', (tester) async {
    await mount(tester);
    // It is the fifth card, below the fold.
    await tester.dragUntilVisible(
      find.text('Breathing'),
      find.byType(SingleChildScrollView),
      Offset(0, -200.v),
    );
    await tester.pumpAndSettle();

    await expectLater(find.byType(ProfileCheckins),
        matchesGoldenFile('goldens/profile_checkins_breathing.png'));
  });

  testWidgets('every badge is round, Breathing included', (tester) async {
    await mount(tester);

    // One per card. The two Explore photos only looked circular because
    // their corners are drawn away; Breathing's is a flat photo, so
    // without the clip it sat there as a rectangle.
    expect(find.byType(ClipOval), findsNWidgets(CheckinKind.values.length));
  });

  testWidgets('the cards are the frame’s own five', (tester) async {
    await mount(tester);
    for (final kind in CheckinKind.values) {
      expect(find.text(kind.title), findsOneWidget);
    }
    // Breathing is not something you document, so it says what it is.
    expect(find.text('Take a minute to\nbreathe and settle'), findsOneWidget);
  });
}
