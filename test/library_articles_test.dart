import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/media_entry.dart';
import 'package:soothifyafrica/app/data/models/library_section.dart';
import 'package:soothifyafrica/app/data/models/media_item.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/modules/user/library/controller/library_controller.dart';
import 'package:soothifyafrica/app/modules/user/library/library_screen.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';

import 'helpers.dart';

/// A library with three articles -- what Stretch & Restore has live.
///
/// The shelf used to put every article into one Row, so three squeezed
/// into the width of two. The mock's fixtures have two each, which is
/// exactly why no test saw it.
class _ThreeArticles extends MockContentRepository {
  static MediaItem _article(String id, String title) => MediaItem(
        id: id,
        title: title,
        type: MediaType.article,
        durationSeconds: 0,
      );

  @override
  Future<List<MediaItem>> getShelf(
    String query, {
    Map<String, String> filters = const {},
  }) async {
    if (query.endsWith('-articles')) {
      return [
        _article('71', 'First piece'),
        _article('72', 'Second piece'),
        _article('73', 'Third piece'),
      ];
    }
    return super.getShelf(query, filters: filters);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
  });
  tearDown(Get.reset);

  Future<void> mount(WidgetTester tester, {List<GetPage<dynamic>>? pages}) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put<ContentRepository>(_ThreeArticles());
    Get.lazyPut(
      () => LibraryController(Get.find<ContentRepository>(), LibrarySection.balance),
    );
    await pumpScreen(tester, const LibraryScreen(), pages: pages);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  }

  Future<void> scrollToArticles(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('Articles'), 300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('three articles show as two, side by side', (tester) async {
    await mount(tester);
    await scrollToArticles(tester);

    expect(find.text('First piece'), findsOneWidget);
    expect(find.text('Second piece'), findsOneWidget);
    expect(find.text('Third piece'), findsNothing,
        reason: 'the third belongs on See All, not squeezed into the row');
  });

  testWidgets('each of the two keeps a full half of the width', (tester) async {
    // Squeezing three in shrank every cover. Two at roughly half the
    // content width is what the frames draw.
    await mount(tester);
    await scrollToArticles(tester);

    final width = tester.getSize(find.text('First piece')).width;
    final screen = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(width, lessThan(screen / 2));
    final cover = tester.getSize(find.ancestor(
      of: find.byType(ClipRRect),
      matching: find.byType(AspectRatio),
    ).last);
    expect(cover.width, greaterThan(screen / 2 - 48),
        reason: 'a cover narrower than this means three are sharing the row');
  });

  testWidgets('the shelf has a See All, like every other', (tester) async {
    await mount(tester);
    await scrollToArticles(tester);

    final heading = find.text('Articles');
    final seeAll = find.text('See All');
    expect(seeAll, findsWidgets);
    // The one level with the Articles heading.
    final headingY = tester.getCenter(heading).dy;
    expect(
      seeAll.evaluate().any(
            (e) => (tester.getCenter(find.byWidget(e.widget)).dy - headingY).abs() < 4,
          ),
      isTrue,
      reason: 'no See All on the Articles row',
    );
  });

  testWidgets('See All opens every article on the shelf page', (tester) async {
    Map<String, dynamic>? opened;
    await mount(tester, pages: [
      GetPage(
        name: AppRoutes.shelf,
        page: () {
          opened = Map<String, dynamic>.from(Get.arguments as Map);
          return const Text('shelf page');
        },
      ),
    ]);
    await scrollToArticles(tester);

    final headingY = tester.getCenter(find.text('Articles')).dy;
    final target = find.text('See All').evaluate().firstWhere(
          (e) => (tester.getCenter(find.byWidget(e.widget)).dy - headingY).abs() < 4,
        );
    await tester.tap(find.byWidget(target.widget));
    await tester.pumpAndSettle();

    expect(find.text('shelf page'), findsOneWidget);
    // The server's own query, so the page lists the same articles.
    expect(opened?['key'], 'balance-articles');
  });

  group('openMedia', () {
    List<GetPage<dynamic>> routes() => [
          GetPage(name: AppRoutes.media, page: () => const Text('player')),
          GetPage(name: AppRoutes.article, page: () => const Text('reader')),
        ];

    testWidgets('an article opens the reader, from anywhere', (tester) async {
      // Every card in the app goes through this -- search, favourites,
      // history, See All. An article from any of them used to open the
      // media player: a scrubber, and no words.
      await pumpScreen(tester, const SizedBox.shrink(), pages: routes());
      openMedia(
        const MediaItem(
          id: '9', title: 'A piece', type: MediaType.article, durationSeconds: 0,
        ),
        source: 'Search',
      );
      await tester.pumpAndSettle();
      expect(find.text('reader'), findsOneWidget);
      expect(find.text('player'), findsNothing);
    });

    testWidgets('audio and video still open the player', (tester) async {
      await pumpScreen(tester, const SizedBox.shrink(), pages: routes());
      openMedia(
        const MediaItem(
          id: '1', title: 'A track', type: MediaType.audio, durationSeconds: 60,
        ),
        source: 'Search',
      );
      await tester.pumpAndSettle();
      expect(find.text('player'), findsOneWidget);
    });
  });
}
