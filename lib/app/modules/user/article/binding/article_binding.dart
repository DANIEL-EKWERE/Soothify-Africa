import 'package:get/get.dart';

import '../../../../data/models/library_section.dart';
import '../../../../data/models/media_item.dart';
import '../controller/article_controller.dart';

/// Takes the article from the route arguments, so one route serves all of
/// them.
///
/// Either a bare MediaItem, or one paired with the section it was opened
/// from — the library knows which row it came off, and that is a better
/// answer than guessing from the category.
class ArticleBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    Get.lazyPut(() {
      if (args is ArticleArguments) {
        return ArticleController(args.item, section: args.section);
      }
      return ArticleController(
        // Only reached if the route is opened with nothing, which the app
        // never does; an empty reader beats a crash.
        args is MediaItem
            ? args
            : const MediaItem(
                id: '',
                title: '',
                type: MediaType.article,
                durationSeconds: 0,
              ),
      );
    });
  }
}

/// An article and the section it was opened from.
class ArticleArguments {
  const ArticleArguments({required this.item, required this.section});

  final MediaItem item;
  final LibrarySection section;
}
