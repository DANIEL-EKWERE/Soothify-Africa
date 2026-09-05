import '../models/media_item.dart';

/// The contract every screen codes against.
///
/// Controllers depend on this interface, never on an HTTP client. That is what
/// lets the app run fully against mock data today and switch to the Django API
/// later without touching a single UI file.
abstract class ContentRepository {
  Future<List<Category>> getCategories();

  Future<List<MediaItem>> getFeatured();

  /// Most recently opened, newest first — the Discovery "Recent" shelf.
  Future<List<MediaItem>> getRecent();

  /// The full "Recommended for you" page. A different, longer set than
  /// [getFeatured], which backs Home's preview row.
  Future<List<MediaItem>> getRecommendations();

  /// One named library shelf — "voice-overs", "sound-effects", "yoga-flow",
  /// "sounds". Each frame gives its shelves different cards.
  Future<List<MediaItem>> getShelf(String query);

  /// The full page behind a shelf's "See All" — a longer, separate list.
  Future<List<MediaItem>> getShelfPage(String shelf);

  Future<List<MediaItem>> getByCategory(String categoryId);

  Future<MediaItem?> getById(String id);

  Future<List<MediaItem>> search(String query);
}
