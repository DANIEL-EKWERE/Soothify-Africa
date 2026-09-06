import '../../data/models/media_item.dart';
import '../app_export.dart';

/// Opens a media item's detail screen.
///
/// Shared by every card in the app — Home, Discovery, the libraries, the See
/// All grid and the coach profile — so they cannot drift into opening
/// different things. [source] names the shelf the card was tapped on, which
/// the detail header shows.
Future<void> openMedia(MediaItem item, {required String source}) =>
    Get.toNamed(AppRoutes.media, arguments: {'item': item, 'source': source})
        as Future<void>;
