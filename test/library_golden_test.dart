import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/library_section.dart';
import 'package:soothifyafrica/app/modules/user/discovery/widgets/discovery_card.dart';
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
        await precacheAll(tester, find.byType(LibraryScreen), libraryCovers);

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

      // The covers are the same shape as every other media card.
      //
      // They were a landscape rectangle beside cards that were not: a fixed
      // `136.v` height against a width that comes from Expanded. Checked as
      // a size rather than left to the goldens, because a golden says only
      // that a screenshot changed, not which way the shape went.
      final covers = tester.widgetList<AspectRatio>(
        find.ancestor(
          of: find.byType(ClipRRect),
          matching: find.byType(AspectRatio),
        ),
      );
      expect(covers, isNotEmpty, reason: 'no article cover found');
      for (final cover in covers) {
        expect(cover.aspectRatio, DiscoveryCard.aspect);
      }

      Get.reset();
    }
  });

  testWidgets('an article cover is the same shape as a media card',
      (tester) async {
    // It was a landscape rectangle beside cards that were not: the shelf
    // set a fixed `136.v` height against a width that comes from Expanded,
    // so the shape depended on the screen and matched nothing.
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put<ContentRepository>(MockContentRepository());
    Get.put(
      LibraryController(Get.find<ContentRepository>(), LibrarySection.balance),
    );

    await pumpScreen(tester, const LibraryScreen());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    final covers = tester.widgetList<AspectRatio>(
      find.descendant(
        of: find.ancestor(
          of: find.text('Articles'),
          matching: find.byType(Column),
        ).last,
        matching: find.byType(AspectRatio),
      ),
    );
    expect(covers, isNotEmpty, reason: 'no article covers were rendered');
    for (final cover in covers) {
      expect(cover.aspectRatio, DiscoveryCard.aspect);
      // And that shape is square to within a few percent, which is what
      // "square like the others" means on the frame.
      expect(cover.aspectRatio, closeTo(1, 0.05));
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
