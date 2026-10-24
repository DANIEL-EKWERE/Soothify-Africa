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
    DateTime Function()? now,
  })  : _profiles = profiles,
        _now = now ?? DateTime.now;

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

  final RxList<MediaItem> recommended = <MediaItem>[].obs;
  final RxList<MediaItem> popular = <MediaItem>[].obs;

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
      final results = await Future.wait([
        _repository.getFeatured(),
        _repository.getPopular(),
      ]);
      recommended.assignAll(results[0]);
      popular.assignAll(results[1]);
    });
  }

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

  /// Home's Popular Content row is the one "See All" in the app with nothing
  /// behind it. It opens the Videos catalogue (`259:60948`), which is the
  /// full browse page for this kind of card — the frames draw no entry point
  /// for that screen, so this placement is a decision, not the design's.
  void seeAllPopular() => Get.toNamed(AppRoutes.videos);
}
