import '../models/media_item.dart';
import 'content_repository.dart';

/// Local stand-in for the Django API, which does not exist yet.
///
/// Deliberately mimics real conditions — it is asynchronous and adds latency —
/// so loading and empty states get exercised during development rather than
/// discovered when the backend lands.
class MockContentRepository implements ContentRepository {
  static const _latency = Duration(milliseconds: 400);

  static const List<Category> _categories = [
    Category(id: 'calm', name: 'Calm', description: 'Wind down and settle'),
    Category(id: 'sleep', name: 'Sleep', description: 'Drift off gently'),
    Category(id: 'focus', name: 'Focus', description: 'Find your rhythm'),
    Category(id: 'breathe', name: 'Breathwork', description: 'Guided breathing'),
    Category(id: 'stories', name: 'Stories', description: 'Told by our voices'),
  ];

  /// Mirrors the sample content in the Figma Home screen, so the screen
  /// renders as designed rather than against unrelated placeholder copy.
  static const List<MediaItem> _items = [
    MediaItem(
      id: '1',
      title: 'Daily focus',
      subtitle: 'Burnout relief',
      tag: 'Meditation',
      type: MediaType.audio,
      durationSeconds: 2700,
      categoryId: 'focus',
      practitionerName: 'Jacob Samuel',
    ),
    MediaItem(
      id: '2',
      title: 'Breath work',
      subtitle: 'Burnout relief',
      tag: 'Meditation',
      type: MediaType.audio,
      durationSeconds: 2700,
      categoryId: 'breathe',
      practitionerName: 'Jacob Samuel',
    ),
    MediaItem(
      id: '3',
      title: 'Mindfulness',
      subtitle: 'Ease frustration',
      tag: 'Sound effect',
      type: MediaType.audio,
      durationSeconds: 2700,
      categoryId: 'calm',
      practitionerName: 'Jacob Samuel',
      isFree: false,
    ),
    MediaItem(
      id: '4',
      title: 'Unshakeable',
      subtitle: 'Popular',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      categoryId: 'popular',
      practitionerName: 'Jacob Samuel',
    ),
    MediaItem(
      id: '5',
      title: 'Hope in the Shadows',
      subtitle: 'Popular',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      categoryId: 'popular',
      practitionerName: 'Jacob Samuel',
    ),
    MediaItem(
      id: '6',
      title: 'Breaking Bad Habit',
      subtitle: 'Popular',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      categoryId: 'popular',
      practitionerName: 'Jacob Samuel',
    ),
    // The three the Discovery "Popular" shelf names, which the Home screen's
    // own popular row does not carry.
    MediaItem(
      id: '7',
      title: 'Awakening sunrise flow',
      subtitle: 'Popular',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      categoryId: 'discovery-popular',
      practitionerName: 'Jacob Samuel',
    ),
    MediaItem(
      id: '8',
      title: 'Midday harmony',
      subtitle: 'Popular',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      categoryId: 'discovery-popular',
      practitionerName: 'Jacob Samuel',
    ),
    MediaItem(
      id: '9',
      title: 'Evening rejuvenation',
      subtitle: 'Popular',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      categoryId: 'discovery-popular',
      practitionerName: 'Jacob Samuel',
    ),
  ];

  @override
  Future<List<Category>> getCategories() async {
    await Future<void>.delayed(_latency);
    return _categories;
  }

  /// Shelves that are fetched by their own query. Excluded from the featured
  /// list explicitly, so adding a shelf cannot silently grow Home's
  /// "Recommended for you" row — which is exactly what adding the Discovery
  /// items did when this tested `!= 'popular'`.
  static const Set<String> _shelfCategories = {'popular', 'discovery-popular'};

  @override
  Future<List<MediaItem>> getFeatured() async {
    await Future<void>.delayed(_latency);
    return _items
        .where((i) => !_shelfCategories.contains(i.categoryId))
        .toList();
  }

  /// The design's Recent shelf shows Unshakeable, Breaking Bad Habit and
  /// Hope in the Shadows. Nothing records real history yet, so this is a
  /// fixed list rather than a lie about what was played.
  @override
  Future<List<MediaItem>> getRecent() async {
    await Future<void>.delayed(_latency);
    const ids = {'4', '6', '5'};
    return _items.where((i) => ids.contains(i.id)).toList();
  }

  @override
  Future<List<MediaItem>> getByCategory(String categoryId) async {
    await Future<void>.delayed(_latency);
    return _items.where((i) => i.categoryId == categoryId).toList();
  }

  @override
  Future<MediaItem?> getById(String id) async {
    await Future<void>.delayed(_latency);
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<List<MediaItem>> search(String query) async {
    await Future<void>.delayed(_latency);
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _items
        .where((i) =>
            i.title.toLowerCase().contains(q) ||
            i.practitionerName.toLowerCase().contains(q))
        .toList();
  }
}
