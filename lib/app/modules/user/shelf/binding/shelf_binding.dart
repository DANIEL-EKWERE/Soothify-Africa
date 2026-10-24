import 'package:get/get.dart';

import '../../../../data/repositories/content_repository.dart';
import '../controller/shelf_controller.dart';

/// Takes the shelf's name from the route arguments, so one route serves every
/// "See All" in the app.
///
/// A map instead of a bare string carries the shelf's server key, and asks
/// for the search row — the Videos screen's See All (`259:61062`) draws one
/// above the grid, and no other caller does.
class ShelfBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    // `key` is the server's slug for the shelf; without one the controller
    // slugifies the heading, which is right for the callers whose heading
    // is the slug and wrong for nobody that passes a key.
    final (shelf, key, search) = switch (args) {
      String s => (s, '', false),
      Map m => (
          '${m['shelf'] ?? 'Sounds'}',
          '${m['key'] ?? ''}',
          m['search'] == true,
        ),
      _ => ('Sounds', '', false),
    };
    Get.lazyPut(
      () => ShelfController(
        Get.find<ContentRepository>(),
        shelf,
        key: key,
        showSearch: search,
      ),
    );
  }
}
