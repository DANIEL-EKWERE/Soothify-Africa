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
  ///
  /// [mood] is a Mood Checker result -- a `MoodLevel.key`. Given one, the
  /// server leads with what staff tagged for that mood and pads with
  /// untagged picks, never with content tagged for a different mood.
  Future<List<MediaItem>> getRecommendations({String mood});

  /// Home's "Popular Content" row, and Discovery's.
  ///
  /// Ordered by the server from what people are actually playing, with
  /// anything staff pinned at the front. It used to be a category called
  /// "popular", which does not exist — so the row was empty on the real
  /// server and full only against the mock.
  Future<List<MediaItem>> getPopular();

  /// What this person has hearted, newest first. Needs a token.
  Future<List<MediaItem>> getFavourites();

  /// Fill or empty the heart. Returns the item as the server now holds it.
  Future<MediaItem> setFavourite(String id, {required bool on});

  /// One named library shelf — "pilates-movement", "balance-rest",
  /// "sounds". Each frame gives its shelves different cards.
  Future<List<MediaItem>> getShelf(String query);

  /// The full page behind a shelf's "See All" — a longer, separate list.
  Future<List<MediaItem>> getShelfPage(String shelf);

  Future<List<MediaItem>> getByCategory(String categoryId);

  Future<MediaItem?> getById(String id);

  Future<List<MediaItem>> search(String query);

  /// Everything of one kind — video, article or audio.
  ///
  /// What the practitioner's recommendation picker lists: the frames split
  /// the library by kind before anything else, because "recommend a video"
  /// is the decision already made by the time the picker opens.
  Future<List<MediaItem>> byKind(MediaType kind, {String query = ''});

  /// Records that this item was listened to, and for how long.
  ///
  /// What the Profile tab's "meditation minutes" is counted from, and what
  /// fills the Recent shelf, so it is sent when a play ends rather than when
  /// one starts — a card opened and closed is not a session.
  Future<void> recordPlay(
    String id, {
    int secondsListened = 0,
    bool completed = false,
  });

  /// One to five stars. Returns the item's new average, which is what the
  /// screen shows afterwards.
  Future<double> rate(String id, int stars);
}
