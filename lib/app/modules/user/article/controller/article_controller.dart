import '../../../../core/app_export.dart';
import '../../../../core/utils/wellness_entry.dart';
import '../../../../data/models/article.dart';
import '../../../../data/models/library_section.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/models/wellness_kyc.dart';

/// Backs the article reader — Figma "Pilates & Core Articles" (`259:58647`)
/// and "Stretch Articles" (`259:58687`).
///
/// One route for both: the frames differ only in their words.
///
/// The article is an ordinary MediaItem now. It used to be one of two
/// values in an enum, with its title, body and closing paragraph written
/// into the app -- so adding a third meant shipping a release.
class ArticleController extends GetxController {
  ArticleController(this.item, {LibrarySection? section})
      : section = section ?? _sectionOf(item);

  final MediaItem item;

  /// Which half of the app it belongs to. Decides where the closing
  /// paragraph's two links go.
  final LibrarySection section;

  String get title => item.title;

  String get body => item.description;

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
