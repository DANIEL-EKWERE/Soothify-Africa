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
import 'package:soothifyafrica/app/data/models/article.dart';

/// Regenerate with:
///   flutter test --update-goldens test/library_golden_test.dart
// PNGs only: precacheImage decodes raster data, and handing it an SVG
// fails with "Invalid image data". flutter_svg loads those itself.
const _covers = [
  'assets/images/explore/pilates_core.png',
  'assets/images/explore/stretch_restore.png',
  'assets/images/library/balance_session.png',
  'assets/images/library/meditation_session.png',
  'assets/images/library/sleep_stories.png',
  'assets/images/content/cover_d.png',
  // Stretch & Restore's own five, lifted from the redrawn frame.
  'assets/images/content/yoga_vinyasa.png',
  'assets/images/content/yoga_hatha.png',
  'assets/images/content/yoga_restorative.png',
  'assets/images/content/rest_sleep.png',
  'assets/images/content/rest_ambient.png',
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
    // The redraw (`259:24767`) closes on an Articles shelf and a promo. The
    // single wide Sleep Stories card it used to carry is gone — "Home
    // Reformer Guides" is a shelf like the two beside it now.
    expect(find.text('Articles'), findsOneWidget);
    expect(find.text('Sleep Stories'), findsNothing);
    expect(find.text(Article.core.title), findsOneWidget);
    expect(find.text('Pilates & Core sessions'), findsOneWidget);
    expect(find.text('Speak with a Pilates training coach'), findsOneWidget);
  });

  testWidgets('both libraries close on the same Articles shelf',
      (tester) async {
    for (final section in LibrarySection.values) {
      useDesignFrame(tester);
      await loadAppFonts();
      Get.put<ContentRepository>(MockContentRepository());
      Get.put(LibraryController(Get.find<ContentRepository>(), section));

      await pumpScreen(tester, const LibraryScreen());
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Both redrawn frames open on Movement and end on Articles.
      expect(find.text('Movement'), findsOneWidget, reason: section.title);
      expect(find.text('Articles'), findsOneWidget, reason: section.title);
      for (final article in Article.values) {
        expect(find.text(article.title), findsOneWidget,
            reason: '${section.title}: ${article.title}');
      }
      Get.reset();
    }
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
