import '../../core/network/api_client.dart';
import '../models/media_item.dart';
import 'content_repository.dart';

/// The library, from `/api/v1/content/`.
///
/// Every method here is one request and one mapping. The eight the interface
/// declares map onto six endpoints: search and getByCategory are the same
/// list with a different query, and a shelf's row and its "See All" page are
/// the same shelf with `full=true`.
class ApiContentRepository implements ContentRepository {
  ApiContentRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Category>> getCategories() async {
    final rows = await _api.getList('/content/categories/');
    return rows.map(Category.fromJson).toList();
  }

  @override
  Future<List<MediaItem>> getFeatured() => _items('/content/featured/');

  @override
  Future<List<MediaItem>> getRecent() => _items('/content/recent/');

  @override
  Future<List<MediaItem>> getRecommendations() =>
      _items('/content/recommendations/');

  @override
  Future<List<MediaItem>> getShelf(String query) =>
      _shelf(query, full: false);

  @override
  Future<List<MediaItem>> getShelfPage(String shelf) =>
      _shelf(shelf, full: true);

  @override
  Future<List<MediaItem>> getByCategory(String categoryId) =>
      _items('/content/items/?category=${Uri.encodeQueryComponent(categoryId)}');

  @override
  Future<MediaItem?> getById(String id) async {
    final body = await _api.get('/content/items/$id/');
    return body.isEmpty ? null : MediaItem.fromJson(body);
  }

  @override
  Future<List<MediaItem>> search(String query) {
    final term = query.trim();
    // An empty search returns nothing rather than the whole library, which
    // is what the screen expects and what the server does with `?q=`.
    if (term.isEmpty) return Future.value(const []);
    return _items('/content/items/?q=${Uri.encodeQueryComponent(term)}');
  }

  Future<List<MediaItem>> _items(String path) async {
    final rows = await _api.getList(path);
    return rows.map(MediaItem.fromJson).toList();
  }

  /// A shelf answers with its own envelope — key, title, items — rather than
  /// a bare list, because the row prints the title the server curates.
  Future<List<MediaItem>> _shelf(String key, {required bool full}) async {
    final body = await _api.get(
      '/content/shelves/${Uri.encodeComponent(key)}/${full ? '?full=true' : ''}',
    );
    final items = body['items'];
    if (items is! List) return const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(MediaItem.fromJson)
        .toList();
  }

  @override
  Future<void> recordPlay(
    String id, {
    int secondsListened = 0,
    bool completed = false,
  }) async {
    // Sent when a listen ends, so the seconds are real. The server caps
    // them at the item's own length, so a miscounting client cannot inflate
    // somebody's meditation minutes.
    await _api.post('/content/items/$id/plays/', body: {
      'seconds_played': secondsListened,
      'completed': completed,
    });
  }

  @override
  Future<double> rate(String id, int stars) async {
    // PUT, not POST: rating again changes your score rather than adding a
    // second one. The item comes back with its new average.
    final body = await _api.put(
      '/content/items/$id/rating/',
      body: {'score': stars},
    );
    return (body['rating'] as num?)?.toDouble() ?? 0;
  }
}
