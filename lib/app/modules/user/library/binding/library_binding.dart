import 'package:get/get.dart';

import '../../../../data/models/library_section.dart';
import '../../../../data/repositories/content_repository.dart';
import '../controller/library_controller.dart';

/// Reads which library to show from the route arguments, so Meditation and
/// Balance share one route contract.
class LibraryBinding extends Bindings {
  @override
  void dependencies() {
    final section = Get.arguments is LibrarySection
        ? Get.arguments as LibrarySection
        : LibrarySection.meditation;
    Get.lazyPut(
      () => LibraryController(Get.find<ContentRepository>(), section),
    );
  }
}
