import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/library_section.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/modules/user/library/controller/library_controller.dart';
import 'package:soothifyafrica/app/modules/user/library/library_screen.dart';
import 'package:soothifyafrica/app/modules/user/schedule/controller/schedule_controller.dart';
import 'package:soothifyafrica/app/modules/user/schedule/schedule_screen.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/library_golden_test.dart
// PNGs only: precacheImage decodes raster data, and handing it an SVG
// fails with "Invalid image data". flutter_svg loads those itself.
const _covers = [
  'assets/images/library/balance_session.png',
  'assets/images/library/meditation_session.png',
  'assets/images/library/sleep_stories.png',
  'assets/images/content/cover_d.png',
  'assets/images/content/cover_a.png',
  'assets/images/content/cover_b.png',
  'assets/images/content/cover_c.png',
  'assets/images/content/unshakeable.png',
  'assets/images/content/hope_in_the_shadows.png',
  'assets/images/content/breaking_bad_habit.png',
  'assets/images/content/daily_focus.png',
  'assets/images/content/breath_work.png',
  'assets/images/content/mindfulness.png',
];

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  for (final section in LibrarySection.values) {
    for (final (name, brightness) in [
      ('light', Brightness.light),
      ('dark', Brightness.dark),
    ]) {
      testWidgets('${section.id}, $name', (tester) async {
        useDesignFrame(tester);
        await loadAppFonts();
        Get.put<ContentRepository>(MockContentRepository());
        Get.lazyPut(
          () => LibraryController(Get.find<ContentRepository>(), section),
        );

        await pumpScreen(tester, const LibraryScreen(),
            brightness: brightness);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();
        await precacheAll(tester, find.byType(LibraryScreen), _covers);

        await expectLater(find.byType(LibraryScreen),
            matchesGoldenFile('goldens/library_${section.id}_$name.png'));
      });
    }
  }

  testWidgets('each library shows the shelves its frame lists', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put<ContentRepository>(MockContentRepository());
    Get.lazyPut(
      () => LibraryController(
        Get.find<ContentRepository>(),
        LibrarySection.meditation,
      ),
    );

    await pumpScreen(tester, const LibraryScreen());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    for (final shelf in LibrarySection.meditation.shelves) {
      expect(find.text(shelf.title), findsOneWidget,
          reason: '${shelf.title} is missing');
    }
    // The frame puts a Sleep Stories card between the two shelves and closes
    // with a sessions promo; both were absent from the first build.
    expect(find.text('Sleep Stories'), findsOneWidget);
    expect(find.text('Calm narratives to help you sleep better'),
        findsOneWidget);
    expect(find.text('Meditation sessions'), findsOneWidget);
    expect(find.text('Speak with a meditation therapist'), findsOneWidget);
  });

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('schedule, $name', (tester) async {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.lazyPut(ScheduleController.new);

      await pumpScreen(tester, const ScheduleScreen(), brightness: brightness);

      await expectLater(find.byType(ScheduleScreen),
          matchesGoldenFile('goldens/schedule_$name.png'));
    });
  }
}
