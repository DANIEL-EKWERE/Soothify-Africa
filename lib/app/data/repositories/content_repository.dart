import '../models/media_item.dart';

import '../models/library_section.dart';
import '../models/media_filter.dart';
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
  ///
  /// [filters] is `FilterSelection.queryParams`. Passed to the server so a
  /// filter narrows the catalogue rather than the page the app happens to
  /// be holding — which is what filtering client-side did, where a chip
  /// could empty a shelf that had matches further down.
  Future<List<MediaItem>> getShelf(String query,
      {Map<String, String> filters});

  /// The full page behind a shelf's "See All" — a longer, separate list.
  Future<List<MediaItem>> getShelfPage(String shelf,
      {Map<String, String> filters});

  Future<List<MediaItem>> getByCategory(String categoryId);

  /// Everything in one half of the app — Pilates & Core, or Stretch &
  /// Restore.
  ///
  /// What the "Start Daily …" screens offer. Those flows are per service,
  /// so they show that service's own content; nothing here is shaped by a
  /// mood check-in.
  Future<List<MediaItem>> bySection(LibrarySection section);

  Future<MediaItem?> getById(String id);

  Future<List<MediaItem>> search(String query,
      {Map<String, String> filters});

  /// What the filter sheets offer, from `/content/filters/`.
  ///
  /// Asked for once and adopted by [FilterCatalogue]. The app used to ship
  /// these lists, which is how its Teacher sheet came to name seven people
  /// who do not practise here.
  Future<void> loadFilterOptions();

  /// Everything of one kind — video, article or audio.
  ///
  /// What the practitioner's recommendation picker lists: the frames split
  /// the library by kind before anything else, because "recommend a video"
  /// is the decision already made by the time the picker opens.
  Future<List<MediaItem>> byKind(MediaType kind,
      {String query, Map<String, String> filters});

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
