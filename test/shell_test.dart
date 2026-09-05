import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/data/models/app_tab.dart';
import 'package:soothifyafrica/app/data/models/media_item.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/modules/user/shell/controller/shell_controller.dart';
import 'package:soothifyafrica/app/modules/user/shell/tabs/home_tab_controller.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(Get.reset);

  group('AppTab', () {
    test('carries the five designed destinations in order', () {
      expect(
        AppTab.values.map((t) => t.label),
        ['Home', 'Plans', 'Discovery', 'Community', 'Profile'],
      );
    });
  });

  group('ShellController', () {
    test('starts on Home and switches by index', () {
      final c = ShellController();
      expect(c.current.value, AppTab.home);
      expect(c.index, 0);

      c.select(3);
      expect(c.current.value, AppTab.community);
      expect(c.index, 3);
    });
  });

  group('HomeTabController', () {
    test('loads the two content rows the design has', () async {
      final c = HomeTabController(MockContentRepository())..onInit();
      await Future<void>.delayed(const Duration(milliseconds: 600));

      expect(c.recommended, isNotEmpty);
      expect(c.popular, isNotEmpty);
      // The rows must not overlap — Popular is its own shelf.
      expect(
        c.recommended.map((m) => m.id).toSet()
            .intersection(c.popular.map((m) => m.id).toSet()),
        isEmpty,
      );
    });

    test('Explore is three fixed destinations, not loaded content', () {
      final c = HomeTabController(MockContentRepository());
      expect(
        c.explore.map((d) => d.label),
        ['Meditation', 'Schedule Session', 'Balance'],
      );
    });

    test('reports failure rather than showing an empty screen', () async {
      final c = HomeTabController(_FailingContentRepository())..onInit();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(c.hasError, isTrue);
      expect(c.recommended, isEmpty);
    });
  });
}

class _FailingContentRepository implements ContentRepository {
  @override
  Future<List<Category>> getCategories() async => throw Exception('offline');
  @override
  Future<List<MediaItem>> getFeatured() async => throw Exception('offline');
  @override
  Future<List<MediaItem>> getRecent() async => throw Exception('offline');
  @override
  Future<List<MediaItem>> getShelf(String query) async =>
      throw Exception('offline');
  @override
  Future<List<MediaItem>> getRecommendations() async =>
      throw Exception('offline');
  @override
  Future<List<MediaItem>> getShelfPage(String shelf) async =>
      throw Exception('offline');
  @override
  Future<List<MediaItem>> getByCategory(String categoryId) async => const [];
  @override
  Future<MediaItem?> getById(String id) async => null;
  @override
  Future<List<MediaItem>> search(String query) async => const [];
}
