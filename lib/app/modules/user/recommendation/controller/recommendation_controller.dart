import 'package:get/get.dart';

import '../../../../core/base_controller.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/repositories/content_repository.dart';

/// Backs the full "Recommended for you" list.
///
/// Not Home's row enlarged: the frame lists five cards with their own
/// practitioners, so this has its own query.
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
    final result = await guard(() => _repository.getRecommendations());
    if (result != null) items.assignAll(result);
  }

  Future<void> reload() => load();
}
