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

  Future<List<MediaItem>> getByCategory(String categoryId);

  Future<MediaItem?> getById(String id);

  Future<List<MediaItem>> search(String query);
}
