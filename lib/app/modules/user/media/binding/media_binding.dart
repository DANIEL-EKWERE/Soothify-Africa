import 'package:get/get.dart';

import '../../../../data/models/media_item.dart';
import '../../../../data/repositories/content_repository.dart';
import '../controller/media_controller.dart';

/// Takes the item and the shelf it came from as route arguments.
///
/// Both shapes are accepted. The cast used to be unconditional, so a caller
/// that passed the item on its own -- which the Daily screen did -- threw
/// here, left the controller unbuilt and opened a blank grey screen with no
/// hint of what went wrong. Everything should go through `openMedia`; this
/// is the net under it.
class MediaBinding extends Bindings {
  @override
  void dependencies() => bindMedia(Get.arguments);
}

/// Reads the route arguments and registers the controller, if it can.
///
/// Separate from [MediaBinding] so the rule can be exercised directly:
/// GetX offers no way to set `Get.arguments` in a test, and this rule is
/// the whole of what went wrong.
void bindMedia(Object? args) {
  final item = args is Map ? args['item'] : args;
  if (item is! MediaItem) return;

  Get.lazyPut(() => MediaController(
        item,
        Get.find<ContentRepository>(),
        source: args is Map ? args['source'] as String? ?? '' : '',
      ));
}
