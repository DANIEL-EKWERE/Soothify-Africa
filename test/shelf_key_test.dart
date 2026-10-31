import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soothifyafrica/app/core/app_export.dart';
import 'package:soothifyafrica/app/data/models/library_section.dart';
import 'package:soothifyafrica/app/data/models/media_item.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/modules/user/library/controller/library_controller.dart';
import 'package:soothifyafrica/app/modules/user/shelf/binding/shelf_binding.dart';
import 'package:soothifyafrica/app/modules/user/shelf/controller/shelf_controller.dart';
import 'package:soothifyafrica/app/modules/user/videos/controller/videos_controller.dart';

/// Which shelf a "See All" actually asks for.
///
/// The API routes shelves by slug — `/content/shelves/voice-overs/` — and
/// the app was passing the heading, so "Voice Overs" 404'd and every grid
/// came back empty against the live backend. The heading and the slug are
/// not derivable from each other either: "Movement" is `voice-overs` in one
/// library section and `yoga-flow` in the other.
void main() {
  // Recorded navigation still reaches for the widgets binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  /// Records what the grid asked the server for.
  late _RecordingRepository repository;

  setUp(() {
    repository = _RecordingRepository();
    Get.put<ContentRepository>(repository);
  });

  ShelfController openedWith(Object? arguments) {
    Get.testMode = true;
    // The binding is what reads the route arguments, so it is what is
    // under test rather than the controller's own constructor.
    final shelf = switch (arguments) {
      Map m => '${m['shelf']}',
      String s => s,
      _ => 'Sounds',
    };
    final key = switch (arguments) {
      Map m => '${m['key'] ?? ''}',
      _ => '',
    };
    return ShelfController(repository, shelf, key: key);
  }

  test('a shelf is fetched by its key, not by its heading', () async {
    final c = openedWith({'shelf': 'Movement', 'key': 'voice-overs'});
    await c.load();
    expect(repository.askedFor, ['voice-overs']);
  });

  test('a caller with no key falls back to the slug of the heading', () async {
    final c = openedWith('Sound Effects');
    await c.load();
    expect(repository.askedFor, ['sound-effects']);
  });

  test('the two content rows repeat their own call, not a shelf', () async {
    await openedWith({'shelf': 'Recent', 'key': 'recent'}).load();
    await openedWith({'shelf': 'Popular Content', 'key': 'popular'}).load();
    expect(repository.askedFor, isEmpty, reason: 'neither is a shelf');
    expect(repository.recentCalls, 1);
    // getPopular, which is what fills the rows — not getFeatured, which is
    // a different list the grid used to open on.
    expect(repository.popularCalls, 1);
    expect(repository.featuredCalls, 0);
  });

  /// Opening for real: the binding is what reads the route arguments, so
  /// the only honest check of what a caller passed is the controller the
  /// route built from it.
  Future<void> mountApp(WidgetTester tester) async {
    // Permanent, because GetX clears a route's dependencies as routes come
    // and go and these tests open the grid several times over.
    Get.put<ContentRepository>(repository, permanent: true);
    await tester.pumpWidget(
      GetMaterialApp(
        home: const SizedBox.shrink(),
        getPages: [
          GetPage(
            name: AppRoutes.shelf,
            page: () => const SizedBox.shrink(),
            binding: ShelfBinding(),
          ),
        ],
      ),
    );
  }

  Future<ShelfController> opened(
    WidgetTester tester,
    void Function() open,
  ) async {
    open();
    await tester.pumpAndSettle();
    final c = Get.find<ShelfController>();
    Get.back();
    await tester.pumpAndSettle();
    return c;
  }

  testWidgets('the binding carries the key through the route',
      (tester) async {
    await mountApp(tester);
    final c = await opened(
      tester,
      () => Get.toNamed(
        AppRoutes.shelf,
        arguments: {'shelf': 'Pilates', 'key': 'videos-pilates'},
      ),
    );
    expect(c.shelf, 'Pilates');
    expect(c.key, 'videos-pilates');
  });

  testWidgets('the library hands over the shelf’s own query',
      (tester) async {
    await mountApp(tester);
    for (final section in LibrarySection.values) {
      final library = LibraryController(repository, section);
      for (final shelf in section.shelves) {
        final c = await opened(tester, () => library.openShelf(shelf.title));
        expect(c.key, shelf.query,
            reason: '${shelf.title} is ${shelf.query} on the server');
      }
    }
  });

  testWidgets('Videos hands over its row’s query', (tester) async {
    await mountApp(tester);
    final videos = VideosController(repository);
    for (final shelf in VideosController.catalogue) {
      final c = await opened(tester, () => videos.openShelf(shelf.title));
      expect(c.key, shelf.query);
      expect(c.showSearch, isTrue,
          reason: 'the Videos See All draws a search row');
    }
  });
}

class _RecordingRepository extends MockContentRepository {
  final List<String> askedFor = [];
  int recentCalls = 0;
  int featuredCalls = 0;
  int popularCalls = 0;

  @override
  Future<List<MediaItem>> getShelfPage(String shelf,
      {Map<String, String> filters = const {}}) {
    askedFor.add(shelf);
    return super.getShelfPage(shelf, filters: filters);
  }

  @override
  Future<List<MediaItem>> getRecent() {
    recentCalls++;
    return super.getRecent();
  }

  @override
  Future<List<MediaItem>> getFeatured() {
    featuredCalls++;
    return super.getFeatured();
  }

  @override
  Future<List<MediaItem>> getPopular() {
    popularCalls++;
    return super.getPopular();
  }
}
