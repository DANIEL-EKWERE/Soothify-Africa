import 'package:get/get.dart';

import '../../../../data/repositories/content_repository.dart';
import '../controller/videos_controller.dart';

class VideosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VideosController(Get.find<ContentRepository>()));
  }
}
