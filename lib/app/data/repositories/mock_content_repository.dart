import '../../core/utils/image_constant.dart';
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
      coverAsset: '${ImageConstant.contentDir}/daily_focus.png',
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
      coverAsset: '${ImageConstant.contentDir}/breath_work.png',
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
      coverAsset: '${ImageConstant.contentDir}/mindfulness.png',
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
      coverAsset: '${ImageConstant.contentDir}/cover_a.png',
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
      coverAsset: '${ImageConstant.contentDir}/cover_b.png',
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
      coverAsset: '${ImageConstant.contentDir}/cover_a.png',
      subtitle: 'Popular',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      categoryId: 'popular',
      practitionerName: 'Jacob Samuel',
    ),
    // The "See All" grid (Figma "Balance Content", 135:20135) lists ten
    // cards of its own — different titles and practitioners from any shelf
    // preview.
    MediaItem(
      id: '20',
      title: 'Midnight Rainfall',
      tag: 'Light Rainfall',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      coverAsset: '${ImageConstant.contentDir}/cover_a.png',
      categoryId: 'shelf-page',
      practitionerName: 'Chiamaka Eze',
    ),
    MediaItem(
      id: '21',
      title: 'Morning Drizzle',
      tag: 'Unshakeable',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      coverAsset: '${ImageConstant.contentDir}/cover_b.png',
      categoryId: 'shelf-page',
      practitionerName: 'Kofi Mensah',
    ),
    MediaItem(
      id: '22',
      title: 'Forest Shower',
      tag: 'Rainfall with Birds Chirping',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      coverAsset: '${ImageConstant.contentDir}/cover_c.png',
      categoryId: 'shelf-page',
      practitionerName: 'Zainab Ahmed',
    ),
    MediaItem(
      id: '23',
      title: 'Whispering Wind',
      tag: 'Gentle Wind',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      coverAsset: '${ImageConstant.contentDir}/cover_d.png',
      categoryId: 'shelf-page',
      practitionerName: 'mina BAello',
    ),
    MediaItem(
      id: '24',
      title: 'Raindrop Reverie',
      tag: 'Voice-over with Rainfall',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      coverAsset: '${ImageConstant.contentDir}/cover_a.png',
      categoryId: 'shelf-page',
      practitionerName: 'Chioma Nwosu',
    ),
    MediaItem(
      id: '25',
      title: 'Serene Breeze',
      tag: 'Gentle Breeze',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      coverAsset: '${ImageConstant.contentDir}/cover_b.png',
      categoryId: 'shelf-page',
      practitionerName: 'Emeka Okoro',
    ),
    MediaItem(
      id: '26',
      title: 'Quiet Storm',
      tag: 'Soft Rainfall with Distant Thunder',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      coverAsset: '${ImageConstant.contentDir}/cover_c.png',
      categoryId: 'shelf-page',
      practitionerName: 'Fola Adesina',
    ),
    MediaItem(
      id: '27',
      title: 'Tropical Rainfall',
      tag: 'Facing Fear',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      coverAsset: '${ImageConstant.contentDir}/cover_d.png',
      categoryId: 'shelf-page',
      practitionerName: 'Ifeoma Anya',
    ),
    MediaItem(
      id: '28',
      title: 'Calm Breeze Symphony',
      tag: 'Heavy Rainfall with Distant Wind',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      coverAsset: '${ImageConstant.contentDir}/cover_a.png',
      categoryId: 'shelf-page',
      practitionerName: 'Rita Okafor',
    ),
    MediaItem(
      id: '29',
      title: 'Rainy Night Escape',
      tag: 'Nature Sounds',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      coverAsset: '${ImageConstant.contentDir}/cover_b.png',
      categoryId: 'shelf-page',
      practitionerName: 'Tunde Olawale',
    ),
    // The Recommendation page is not Home's row enlarged — the frame lists
    // five cards with their own practitioners, three of which appear nowhere
    // else (Figma 135:1372).
    MediaItem(
      id: '12',
      title: 'Mindfulness',
      subtitle: 'Mind talks',
      tag: 'Voice over',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      coverAsset: '${ImageConstant.contentDir}/breath_work.png',
      categoryId: 'recommended',
      practitionerName: 'Toluwani Smith',
    ),
    MediaItem(
      id: '13',
      title: 'Sound',
      subtitle: 'Sound relief',
      tag: 'Sound effect',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      coverAsset: '${ImageConstant.contentDir}/mindfulness.png',
      categoryId: 'recommended',
      practitionerName: 'Chidera Michael',
    ),
    MediaItem(
      id: '14',
      title: 'Balance',
      subtitle: 'Vinyasa flow',
      tag: 'Meditation',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      coverAsset: '${ImageConstant.contentDir}/daily_focus.png',
      categoryId: 'recommended',
      practitionerName: 'Naomi James',
    ),
    // The three the Discovery "Popular" shelf names, which the Home screen's
    // own popular row does not carry.
    MediaItem(
      id: '7',
      title: 'Awakening sunrise flow',
      coverAsset: '${ImageConstant.contentDir}/cover_a.png',
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
      coverAsset: '${ImageConstant.contentDir}/cover_b.png',
      subtitle: 'Popular',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      categoryId: 'discovery-popular',
      practitionerName: 'Jacob Samuel',
    ),
    MediaItem(
      id: '10',
      title: 'Breaking Bad Habit',
      subtitle: 'Sound effect',
      tag: 'Sound effect',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      coverAsset: '${ImageConstant.contentDir}/cover_c.png',
      categoryId: 'sound-effects',
      practitionerName: 'Jacob Samuel',
    ),
    MediaItem(
      id: '11',
      title: 'Breaking Bad Habit',
      subtitle: 'Sound effect',
      tag: 'Sound effect',
      type: MediaType.audio,
      durationSeconds: 2700,
      rating: 4.6,
      coverAsset: '${ImageConstant.contentDir}/cover_d.png',
      categoryId: 'sound-effects',
      practitionerName: 'Jacob Samuel',
    ),
    MediaItem(
      id: '9',
      title: 'Evening rejuvenation',
      coverAsset: '${ImageConstant.contentDir}/cover_a.png',
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
  static const Set<String> _shelfCategories = {
    'popular',
    'discovery-popular',
    'sound-effects',
    'recommended',
    'shelf-page',
  };

  @override
  Future<List<MediaItem>> getFeatured() async {
    await Future<void>.delayed(_latency);
    return _items
        .where((i) => !_shelfCategories.contains(i.categoryId))
        .toList();
  }

  /// The library shelves. Each is its own slice: the Meditation frame gives
  /// Voice Overs three cards and Sound Effects two *different* ones, so
  /// serving the same list to both — as a single getRecent() did — put the
  /// wrong art under the wrong heading.
  /// Order matters: the frames lay the two content covers out a/b/a, so the
  /// ids are sequenced to reproduce that rather than sorted by id.
  static const Map<String, List<String>> _shelves = {
    'voice-overs': ['4', '5', '6'],
    'sound-effects': ['10', '11'],
    'yoga-flow': ['7', '8', '9'],
    'sounds': ['10', '11'],
  };

  /// The Recommendation page's own five cards, in the frame's order. Home's
  /// row is a different, shorter set — see [getFeatured].
  @override
  Future<List<MediaItem>> getRecommendations() async {
    await Future<void>.delayed(_latency);
    const ids = ['3', '12', '13', '14', '3'];
    return [
      for (final id in ids) ..._items.where((i) => i.id == id),
    ];
  }

  /// The full page behind a shelf's "See All". The frame shows ten cards in
  /// a two-column grid, independent of the three or four the shelf previews.
  @override
  Future<List<MediaItem>> getShelfPage(String shelf) async {
    await Future<void>.delayed(_latency);
    return _items.where((i) => i.categoryId == 'shelf-page').toList();
  }

  @override
  Future<List<MediaItem>> getShelf(String query) async {
    await Future<void>.delayed(_latency);
    final ids = _shelves[query] ?? const <String>[];
    return [
      for (final id in ids)
        ..._items.where((i) => i.id == id),
    ];
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
