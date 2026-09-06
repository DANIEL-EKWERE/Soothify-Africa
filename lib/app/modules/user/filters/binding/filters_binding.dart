import 'package:get/get.dart';

import '../../../../data/models/media_filter.dart';
import '../controller/filters_controller.dart';

/// Binds the filter flow's single controller.
///
/// All three sheets share this binding. The first one entered creates the
/// controller from the library's current filters; the deeper two find it
/// already registered and leave it alone, so the working selection is not
/// reset halfway through. GetX deletes it when the first sheet pops, which is
/// also when the flow ends.
class FiltersBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<FiltersController>()) return;
    final initial = Get.arguments is FilterSelection
        ? Get.arguments as FilterSelection
        : FilterSelection();
    Get.put(FiltersController(initial));
  }
}
