import 'package:get/get.dart';

import '../../../../data/repositories/content_repository.dart';
import '../controller/shelf_controller.dart';

/// Takes the shelf's name from the route arguments, so one route serves every
/// "See All" in the app.
class ShelfBinding extends Bindings {
  @override
  void dependencies() {
    final shelf = Get.arguments is String ? Get.arguments as String : 'Sounds';
    Get.lazyPut(() => ShelfController(Get.find<ContentRepository>(), shelf));
  }
}
