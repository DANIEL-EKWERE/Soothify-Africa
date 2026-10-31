import 'package:get/get.dart';

import '../../../../core/utils/media_entry.dart';
import '../../../../core/base_controller.dart';
import '../../../../core/utils/feedback_utils.dart';
import '../../../../core/utils/logger.dart';
import '../../../../data/models/explore_destination.dart';
import '../../../../data/models/library_section.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/repositories/content_repository.dart';
import '../../../../data/repositories/mood_repository.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../../../../data/services/session_service.dart';

/// Backs the Home tab.
///
/// Sections come from the design: a Mood Checker entry, three fixed Explore
/// destinations, a "Recommended for you" list and a "Popular Content" row.
class HomeTabController extends BaseController {
  HomeTabController(
    this._repository, {
    ProfileRepository? profiles,
    MoodRepository? moods,
    DateTime Function()? now,
  })  : _profiles = profiles,
        _moods = moods,
        _now = now ?? DateTime.now;

  /// The last Mood Checker result, which shapes the Recommended row.
  ///
  /// Optional for the same reason as [_profiles]: a test or a golden that
  /// only cares about the rows builds this without one, and then the row is
  /// the unshaped list -- which is what somebody who has never checked in
  /// sees anyway.
  final MoodRepository? _moods;

  /// Who is signed in, for the header. Optional: a test that only cares
  /// about the two content rows builds this without one, and the header
  /// then shows the time of day, which is what a guest sees anyway.
  final ProfileRepository? _profiles;

  /// Injectable so the greeting does not make a golden stale by the hour.
  final DateTime Function() _now;

  /// The unsigned header's greeting. The frame prints "Good morning".
  String get greeting {
    final h = _now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// The signed-in person's first name, once it has arrived.
  final RxString firstName = ''.obs;

  /// What the header says to somebody signed in.
  ///
  /// The frame draws "Hi, Dera" -- a name from the design, which shipped as
  /// a literal and greeted every user as Dera. Until the real one arrives
  /// this falls back to the time of day rather than to a placeholder: being
  /// told good morning is no worse than usual, being called by a stranger's
  /// name is.
  String get hello =>
      firstName.value.isEmpty ? greeting : 'Hi, ${firstName.value}';

  final ContentRepository _repository;

  /// The row is a preview of the recommendations page, not a list of its
  /// own: same source, same mood, so the heading "Recommended for you" is
  /// true. Five at most -- [hasMoreRecommended] says whether to offer the
  /// way through to the rest.
  static const previewCount = 5;

  final RxList<MediaItem> recommended = <MediaItem>[].obs;
  final RxList<MediaItem> popular = <MediaItem>[].obs;

  /// Whether there is more behind the row than the five it shows.
  final RxBool hasMoreRecommended = false.obs;

  /// Static, not loaded — these are navigation targets.
  List<ExploreDestination> get explore => ExploreDestination.values;

  /// The part of a name a greeting uses. "Chidera Obi" -> "Chidera".
  static String _firstWord(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  Future<void> _loadName() async {
    final profiles = _profiles;
    if (profiles == null) return;
    // /auth/me/ needs a token. A guest sees the time of day, which is what
    // the frame draws for them anyway, so the request is not made at all.
    //
    // Asked only when there is a session to ask. Get.find throws on an
    // unregistered service, and that throw is outside the try below -- it
    // took the whole greeting down in any test that builds this controller
    // on its own.
    if (Get.isRegistered<SessionService>() &&
        !Get.find<SessionService>().hasAccount) {
      return;
    }
    try {
      firstName.value = _firstWord((await profiles.me()).fullName);
    } catch (_) {
      // A header is not worth an error message. Without the name it shows
      // the time of day, which is a perfectly good greeting.
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadName();
    load();
  }

  Future<void> load() async {
    await guard(() async {
      final mood = await _lastMood();
      final results = await Future.wait([
        _repository.getRecommendations(mood: mood),
        _repository.getPopular(),
      ]);
      final picks = results[0];
      recommended.assignAll(picks.take(previewCount).toList());
      hasMoreRecommended.value = picks.length > previewCount;
      popular.assignAll(results[1]);
    });
  }

  /// The mood of the last check-in, or empty if there has not been one.
  ///
  /// Read from the device, which is where a check-in lands first -- so a
  /// guest who has never signed in still gets a row shaped by how they
  /// said they felt.
  Future<String> _lastMood() async {
    final moods = _moods;
    if (moods == null) return '';
    try {
      final today = await moods.todaysEntry();
      if (today != null) return today.level.key;
      final recent = await moods.history(limit: 1);
      return recent.isEmpty ? '' : recent.first.level.key;
    } catch (error) {
      // No mood is a perfectly good answer; it just means the row is not
      // shaped by one. Never worth costing somebody their home screen.
      Log.e('could not read the last mood for Home', error: error);
      return '';
    }
  }

  /// "See more" under the row -- the full recommendations page.
  void seeAllRecommended() => Get.toNamed(AppRoutes.recommendation);

  Future<void> reload() => load();

  /// Fill or empty the heart on a card.
  ///
  /// Drawn immediately and told to the server after: a heart that waits
  /// for a round trip before it fills reads as a tap that did not land,
  /// and people tap it again. If the call fails the card goes back to what
  /// it was, which is the honest answer.
  Future<void> toggleHeart(MediaItem item) async {
    if (!Get.find<SessionService>().hasAccount) {
      AppFeedback.info('Sign in to keep this.');
      return;
    }

    final wanted = !item.isFavourite;
    _redraw(item.id, wanted);
    try {
      await _repository.setFavourite(item.id, on: wanted);
    } catch (error) {
      _redraw(item.id, item.isFavourite);
      Log.e('could not change the heart', error: error);
    }
  }

  void _redraw(String id, bool hearted) {
    for (final list in [recommended, popular]) {
      final i = list.indexWhere((m) => m.id == id);
      if (i >= 0) list[i] = list[i].copyWith(isFavourite: hearted);
    }
  }

  /// All three Explore tiles now have a screen. Meditation and Balance share
  /// one, distinguished by the argument.
  void openExplore(ExploreDestination destination) {
    switch (destination) {
      case ExploreDestination.meditation:
        Get.toNamed(AppRoutes.library, arguments: LibrarySection.meditation);
      case ExploreDestination.balance:
        Get.toNamed(AppRoutes.library, arguments: LibrarySection.balance);
      case ExploreDestination.scheduleSession:
        // Straight to "Book a licensed expert screen" (`259:31488`), which
        // is where the design puts the choice of discipline. The
        // questionnaire is behind a card on that screen, not in front of it.
        Get.toNamed(AppRoutes.bookExpert);
    }
  }

  /// Any card on Home opens the item's detail.
  void open(MediaItem item, {required String source}) =>
      openMedia(item, source: source);

  /// The rest of the Popular row, in the grid every other "See All" opens.
  ///
  /// It used to open the Videos catalogue, which is two fixed video shelves
  /// — somewhere adjacent, not more of what was tapped, and nothing at all
  /// for the audio and articles this row can hold. The grid repeats the
  /// very call that filled the row, which is what Discovery's Popular
  /// already did.
  void seeAllPopular() => Get.toNamed(
        AppRoutes.shelf,
        arguments: {'shelf': 'Popular Content', 'key': 'popular'},
      );
}
