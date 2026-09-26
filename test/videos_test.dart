import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/modules/user/discovery/widgets/discovery_card.dart';
import 'package:soothifyafrica/app/modules/user/videos/controller/videos_controller.dart';
import 'package:soothifyafrica/app/modules/user/videos/videos_screen.dart';
import 'package:soothifyafrica/app/widgets/content_search_row.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/videos_test.dart
const _covers = [
  'assets/images/content/cover_a.png',
  'assets/images/content/cover_b.png',
  'assets/images/content/cover_c.png',
  'assets/images/content/cover_d.png',
  'assets/images/content/daily_focus.png',
  'assets/images/content/breath_work.png',
  'assets/images/content/mindfulness.png',
  'assets/images/content/unshakeable.png',
  'assets/images/content/breaking_bad_habit.png',
  'assets/images/content/hope_in_the_shadows.png',
];

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<VideosController> mount(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put<ContentRepository>(MockContentRepository());
    final c = Get.put(VideosController(Get.find<ContentRepository>()));
    await pumpScreen(tester, const VideosScreen(), brightness: brightness);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await precacheAll(tester, find.byType(VideosScreen), _covers);
    return c;
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('videos, $name', (tester) async {
      await mount(tester, brightness: brightness);

      await expectLater(find.byType(VideosScreen),
          matchesGoldenFile('goldens/videos_$name.png'));
    });
  }

  testWidgets('a shelf per category, each with its own See All',
      (tester) async {
    final c = await mount(tester);
    expect(find.text('Videos'), findsOneWidget);
    for (final shelf in VideosController.catalogue) {
      expect(find.text(shelf.title), findsOneWidget);
      expect(c.shelves[shelf.title], isNotEmpty);
    }
    expect(find.text('See All'), findsNWidgets(VideosController.catalogue.length));
    expect(find.byType(ContentSearchRow), findsOneWidget);
    expect(find.byType(DiscoveryCard), findsWidgets);
  });

  test('the frame’s "PIlates" typo is not carried into the app', () {
    final titles = VideosController.catalogue.map((s) => s.title);
    expect(titles, contains('Pilates'));
    expect(titles, isNot(contains('PIlates')));
  });

  test('each shelf is its own query, so the rows cannot share a list',
      () async {
    final repo = MockContentRepository();
    final rows = await Future.wait(
      VideosController.catalogue.map((s) => repo.getShelf(s.query)),
    );
    for (final row in rows) {
      expect(row, isNotEmpty, reason: 'every shelf query must resolve');
    }
    expect(rows.first.map((m) => m.id), isNot(rows.last.map((m) => m.id)));
  });
}
