import '../../../../core/app_export.dart';
import '../../../../core/utils/wellness_entry.dart';
import '../../../../data/models/article.dart';
import '../../../../data/models/library_section.dart';
import '../../../../data/models/wellness_kyc.dart';

/// Backs the article reader — Figma "Pilates & Core Articles" (`259:58647`)
/// and "Stretch Articles" (`259:58687`).
///
/// One route for both: the frames differ only in their words.
class ArticleController extends GetxController {
  ArticleController(this.article);

  final Article article;

  /// The closing paragraph's two blue runs. The frames underline nothing and
  /// name no destination, but each phrase says plainly where it goes — into
  /// this article's own library, or into booking a session in it.
  Future<void> follow(ArticleLink link) async {
    switch (link) {
      case ArticleLink.library:
        await Get.toNamed(AppRoutes.library, arguments: article.section);
      case ArticleLink.booking:
        await openBooking(switch (article.section) {
          LibrarySection.meditation => WellnessTrack.meditation,
          LibrarySection.balance => WellnessTrack.balance,
        });
    }
  }
}
