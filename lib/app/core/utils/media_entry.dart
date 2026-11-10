import '../../data/models/media_item.dart';
import '../app_export.dart';

/// Opens a media item: the reader for an article, the player for the rest.
///
/// Shared by every card in the app — Home, Discovery, the libraries, the See
/// All grid, search, favourites, history and the coach profile — so they
/// cannot drift into opening different things. [source] names the shelf the
/// card was tapped on, which the player's header shows.
///
/// The article branch is here rather than at each card because an article
/// can turn up on any of them. It used to be missing, so an article found
/// through search or a See All page opened in the media player, with a
/// scrubber and no words.
Future<void> openMedia(MediaItem item, {required String source}) async {
  if (item.type == MediaType.article) {
    await Get.toNamed(AppRoutes.article, arguments: item);
    return;
  }
  await Get.toNamed(
    AppRoutes.media,
    arguments: {'item': item, 'source': source},
  );
}
