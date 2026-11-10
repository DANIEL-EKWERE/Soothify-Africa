import '../../../../core/app_export.dart';
import '../../../../core/utils/wellness_entry.dart';
import '../../../../core/utils/checkout_launcher.dart';
import '../../../../data/models/article.dart';
import '../../../../data/models/article_body.dart';
import '../../../../data/models/library_section.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/models/wellness_kyc.dart';
import '../../../../data/repositories/content_repository.dart';

/// Backs the article reader — Figma "Pilates & Core Articles" (`259:58647`)
/// and "Stretch Articles" (`259:58687`).
///
/// One route for both: the frames differ only in their words.
///
/// The article is an ordinary MediaItem now. It used to be one of two
/// values in an enum, with its title, body and closing paragraph written
/// into the app -- so adding a third meant shipping a release.
class ArticleController extends GetxController {
  ArticleController(this.item, {LibrarySection? section, ContentRepository? content})
      : section = section ?? _sectionOf(item),
        _content = content;

  final MediaItem item;

  /// Looks up what an embedded link points at. Optional: an article with no
  /// links in it never needs one, and the reader must still open without a
  /// repository registered.
  final ContentRepository? _content;

  ContentRepository? get _repository {
    if (_content != null) return _content;
    return Get.isRegistered<ContentRepository>()
        ? Get.find<ContentRepository>()
        : null;
  }

  /// True while a tapped link is being looked up, so the reader can say so
  /// rather than appearing to ignore the tap.
  final RxBool isFollowing = false.obs;

  /// Which half of the app it belongs to. Decides where the closing
  /// paragraph's two links go.
  final LibrarySection section;

  String get title => item.title;

  String get body => item.description;

  /// The body, split into prose and links.
  ///
  /// An author writes them inline on the dashboard --
  /// `[our Deep Rest sleep story](media:42)` -- so an article can send a
  /// reader straight to the thing it is talking about. See
  /// [parseArticleBody].
  List<ArticleSpan> get bodySpans => parseArticleBody(body);

  /// Whether this article has any links in its body at all.
  bool get bodyHasLinks => bodySpans.any((span) => span.isLink);

  /// The body as the reader lays it out: headings, prose, lists, pictures.
  ///
  /// Parsed once per read rather than cached. An article is a few hundred
  /// words and this runs when the screen is built, so the cost is a
  /// rounding error against laying the text out -- and a cache would be
  /// one more thing to invalidate when the piece is reopened.
  List<ArticleBlock> get bodyBlocks => parseArticleBlocks(body);

  double get rating => item.rating;

  String get cover => item.cover;

  /// The closing paragraph, built from the section rather than written per
  /// article.
  ///
  /// The frames give each article its own sentence, and the server has no
  /// field for one. A call to action an author must hand-write every time
  /// is one that gets skipped, and a half-written article ends on nothing
  /// -- so it is generated, and every article closes the same way.
  List<ArticleRun> get callToAction => [
        const ArticleRun('Ready to go further? '),
        ArticleRun('Explore our complete ${section.title} library',
            link: ArticleLink.library),
        const ArticleRun(' or '),
        const ArticleRun('book a 1-on-1 session with a certified coach',
            link: ArticleLink.booking),
        const ArticleRun(' for a routine of your own.'),
      ];

  /// Which section a piece belongs to, from the shelf it came off.
  ///
  /// The server says so on the shelf, not on the item, so this reads the
  /// category as a stand-in when the caller did not say. Pilates is the
  /// fallback because it is the first tile on Explore.
  static LibrarySection _sectionOf(MediaItem item) =>
      const {'sleep', 'calm', 'stories'}.contains(item.categoryId)
          ? LibrarySection.balance
          : LibrarySection.meditation;

  /// Open what an embedded link points at.
  ///
  /// Nothing here throws: a link to a piece that has since been unpublished
  /// is an authoring mistake, and the reader says so plainly rather than
  /// failing in front of somebody who only tapped a phrase.
  Future<void> followTap(ArticleTap tap) async {
    if (isFollowing.value) return;

    switch (tap.target) {
      case ArticleTarget.external:
        final opened = await ExternalLink.open(tap.id);
        if (!opened) AppFeedback.info('That link could not be opened.');
      case ArticleTarget.library:
        await Get.toNamed(AppRoutes.library, arguments: section);
      case ArticleTarget.booking:
        await follow(ArticleLink.booking);
      case ArticleTarget.breathe:
        await Get.toNamed(AppRoutes.breathe);
      case ArticleTarget.media:
        await _openMedia(tap.id);
    }
  }

  Future<void> _openMedia(String id) async {
    // Linking a piece to itself would push a second copy of this screen on
    // top of the one being read. Harmless but baffling, and an easy thing
    // to do by accident when copying ids.
    if (id == item.id) return;

    final repository = _repository;
    if (repository == null) return;

    isFollowing.value = true;
    try {
      final found = await repository.getById(id);
      if (found == null) {
        AppFeedback.info('That piece is no longer available.');
        return;
      }
      // An article opens the reader; anything else opens the player.
      await Get.toNamed(
        found.type == MediaType.article
            ? AppRoutes.article
            : AppRoutes.media,
        arguments: found,
      );
    } catch (error, stack) {
      Log.e('could not follow an article link', error: error, stackTrace: stack);
      AppFeedback.info('That could not be opened just now.');
    } finally {
      isFollowing.value = false;
    }
  }

  Future<void> follow(ArticleLink link) async {
    switch (link) {
      case ArticleLink.library:
        await Get.toNamed(AppRoutes.library, arguments: section);
      case ArticleLink.booking:
        await openBooking(switch (section) {
          LibrarySection.meditation => WellnessTrack.meditation,
          LibrarySection.balance => WellnessTrack.balance,
        });
    }
  }
}
