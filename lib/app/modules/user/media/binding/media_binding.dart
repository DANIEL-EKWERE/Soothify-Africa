import 'package:get/get.dart';

import '../../../../data/models/media_item.dart';
import '../../../../data/repositories/content_repository.dart';
import '../controller/media_controller.dart';

/// Takes the item and the shelf it came from as route arguments.
class MediaBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    Get.lazyPut(() => MediaController(
          args['item'] as MediaItem,
          Get.find<ContentRepository>(),
          source: args['source'] as String? ?? '',
        ));
  }
}
