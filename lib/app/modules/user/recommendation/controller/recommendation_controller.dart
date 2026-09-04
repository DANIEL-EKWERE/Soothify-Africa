import 'package:get/get.dart';

import '../../../../core/base_controller.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/repositories/content_repository.dart';

/// Backs the full "Recommended for you" list.
///
/// The same rows Home shows in miniature, without the surrounding sections.
class RecommendationController extends BaseController {
  RecommendationController(this._repository);

  final ContentRepository _repository;

  final RxList<MediaItem> items = <MediaItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final result = await guard(() => _repository.getFeatured());
    if (result != null) items.assignAll(result);
  }

  Future<void> reload() => load();
}
