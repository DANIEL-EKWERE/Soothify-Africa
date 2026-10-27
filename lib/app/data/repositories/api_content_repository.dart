import '../../core/network/api_client.dart';
import '../../core/utils/logger.dart';
import '../models/library_section.dart';
import '../models/media_filter.dart';
import '../models/media_item.dart';
import 'content_repository.dart';
import 'kyc_repository.dart';

/// The library, from `/api/v1/content/`.
///
/// Every method here is one request and one mapping. The eight the interface
/// declares map onto six endpoints: search and getByCategory are the same
/// list with a different query, and a shelf's row and its "See All" page are
/// the same shelf with `full=true`.
class ApiContentRepository implements ContentRepository {
  ApiContentRepository(this._api, {KycRepository? kyc}) : _kyc = kyc;

  final ApiClient _api;

  /// Where the onboarding answers live, which is the device. Optional so a
  /// test can build this without one; without it, recommendations are the
  /// staff-picked list, which is what the server falls back to anyway.
  final KycRepository? _kyc;

  @override
  Future<List<Category>> getCategories() async {
    final rows = await _api.getList('/content/categories/');
    return rows.map(Category.fromJson).toList();
  }

  @override
  Future<List<MediaItem>> getFeatured() => _items('/content/featured/');

  @override
  Future<List<MediaItem>> getRecent() => _items('/content/recent/');

  /// Recommendations, shaped by the onboarding questionnaire.
  ///
  /// The answers travel with the request rather than being looked up by
  /// account, because the questionnaire is answered before anybody has one
  /// — a guest on the home screen has to get the same personalisation a
  /// signed-in person does.
  ///
  /// A POST, and not because anything is created: concerns like
  /// "sleep_disorder" in a query string end up in access logs, proxy caches
  /// and the CDN cache key.
  @override
  Future<List<MediaItem>> getRecommendations({String mood = ''}) async {
    final body = await _api.post(
      '/content/recommendations/',
      body: {
        ...await _questionnaire(),
        // Sent in the body rather than the query: the questionnaire goes
        // the same way, and a mood in a URL ends up in access logs.
        if (mood.isNotEmpty) 'mood': mood,
      },
    );
    final rows = body['results'] ?? body['data'] ?? body['items'];
    if (rows is! List) return const [];
    return rows.whereType<Map<String, dynamic>>().map(MediaItem.fromJson).toList();
  }

  /// The two answers that say anything about what to show, if we have them.
  ///
  /// An empty body is a perfectly good request: the server reads the
  /// account's own answers when signed in, and falls back to the staff list
  /// when there is nothing to go on either way.
  Future<Map<String, dynamic>> _questionnaire() async {
    final kyc = _kyc;
    if (kyc == null) return const {};
    try {
      final answers = await kyc.savedAnswers();
      return {
        for (final key in const ['concerns', 'goals'])
          if (answers[key]?.isNotEmpty ?? false) key: answers[key]!.toList(),
      };
    } catch (error) {
      // Corrupt or missing local answers must not cost somebody their home
      // screen; without them the server picks for everyone.
      Log.e('could not read the questionnaire for recommendations', error: error);
      return const {};
    }
  }

  @override
  Future<List<MediaItem>> getShelf(String query,
          {Map<String, String> filters = const {}}) =>
      _shelf(query, full: false, filters: filters);

  @override
  Future<List<MediaItem>> getShelfPage(String shelf,
          {Map<String, String> filters = const {}}) =>
      _shelf(shelf, full: true, filters: filters);

  @override
  Future<List<MediaItem>> getByCategory(String categoryId) =>
      _items('/content/items/?category=${Uri.encodeQueryComponent(categoryId)}');

  @override
  Future<List<MediaItem>> bySection(LibrarySection section) =>
      _items('/content/items/?section=${section.wire}');

  @override
  Future<MediaItem?> getById(String id) async {
    final body = await _api.get('/content/items/$id/');
    return body.isEmpty ? null : MediaItem.fromJson(body);
  }

  @override
  Future<List<MediaItem>> search(String query,
      {Map<String, String> filters = const {}}) {
    final term = query.trim();
    // An empty search returns nothing rather than the whole library, which
    // is what the screen expects and what the server does with `?q=`.
    if (term.isEmpty) return Future.value(const []);
    return _items(
      '/content/items/?q=${Uri.encodeQueryComponent(term)}'
      '${_query(filters, leading: '&')}',
    );
  }

  @override
  Future<void> loadFilterOptions() async {
    final body = await _api.get('/content/filters/');

    final groups = <FilterGroup, List<FilterOption>>{};
    for (final raw in (body['groups'] as List? ?? const [])) {
      if (raw is! Map<String, dynamic>) continue;
      final group = _groupFor(raw['id'] as String? ?? '');
      if (group == null) continue;
      groups[group] = [
        for (final option in (raw['options'] as List? ?? const []))
          if (option is Map<String, dynamic>)
            FilterOption(
              option['slug'] as String? ?? '',
              option['label'] as String? ?? '',
              description: option['description'] as String? ?? '',
            ),
      ];
    }

    // The practitioners, which are not tags: a teacher option carries their
    // id, because that is what content is credited to.
    final teachers = [
      for (final row in (body['teachers'] as List? ?? const []))
        if (row is Map<String, dynamic>)
          FilterOption(
            '${row['id']}',
            row['name'] as String? ?? '',
          ),
    ];
    if (teachers.isNotEmpty) groups[FilterGroup.teacher] = teachers;

    final buckets = [
      for (final minutes in (body['durations'] as List? ?? const []))
        if (minutes is num) minutes.toInt(),
    ];
    if (buckets.isNotEmpty) {
      groups[FilterGroup.duration] = [
        for (final minutes in buckets)
          FilterOption('$minutes', '$minutes minutes'),
      ];
    }

    FilterCatalogue.instance.adopt(groups: groups, durationBuckets: buckets);
  }

  /// The server's group id to the app's enum. An id the app does not know
  /// is skipped rather than guessed, so a group added server-side before
  /// this app ships is simply not offered.
  static FilterGroup? _groupFor(String id) => switch (id) {
        'focus' => FilterGroup.focus,
        'body_part' => FilterGroup.bodyPart,
        'prop' => FilterGroup.prop,
        'music' => FilterGroup.music,
        'style' => FilterGroup.style,
        _ => null,
      };

  /// `tags=a,b&teacher=4` — empty for no filters, so a URL stays clean.
  static String _query(Map<String, String> filters, {String leading = '?'}) {
    if (filters.isEmpty) return '';
    final pairs = filters.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return '$leading$pairs';
  }

  @override
  Future<List<MediaItem>> byKind(MediaType kind,
      {String query = '', Map<String, String> filters = const {}}) {
    final term = query.trim();
    return _items(
      '/content/items/?type=${kind.name}'
      '${term.isEmpty ? '' : '&q=${Uri.encodeQueryComponent(term)}'}'
      '${_query(filters, leading: '&')}',
    );
  }

  @override
  Future<List<MediaItem>> getPopular() => _items('/content/popular/');

  @override
  Future<List<MediaItem>> getFavourites() => _items('/content/favourites/');

  @override
  Future<MediaItem> setFavourite(String id, {required bool on}) async {
    final path = '/content/items/$id/favourite/';
    final body = on ? await _api.post(path) : await _api.delete(path);
    return MediaItem.fromJson(body);
  }

  Future<List<MediaItem>> _items(String path) async {
    final rows = await _api.getList(path);
    return rows.map(MediaItem.fromJson).toList();
  }

  /// A shelf answers with its own envelope — key, title, items — rather than
  /// a bare list, because the row prints the title the server curates.
  Future<List<MediaItem>> _shelf(String key,
      {required bool full, Map<String, String> filters = const {}}) async {
    final query = {
      if (full) 'full': 'true',
      ...filters,
    };
    final body = await _api.get(
      '/content/shelves/${Uri.encodeComponent(key)}/${_query(query)}',
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
