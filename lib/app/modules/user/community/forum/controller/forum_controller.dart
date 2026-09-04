import '../../../../../core/app_export.dart';
import '../../../../../core/base_controller.dart';
import '../../../../../data/models/discussion.dart';
import '../../../../../data/repositories/community_repository.dart';

/// Backs the forum list — Figma "Join discussion" (135:5035).
class ForumController extends BaseController {
  ForumController(this._repository, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final CommunityRepository _repository;

  /// Injectable so "1 hour ago" does not drift in a golden.
  final DateTime Function() _now;

  final RxList<Discussion> discussions = <Discussion>[].obs;
  final RxInt page = 1.obs;

  DateTime get now => _now();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
        discussions.assignAll(await _repository.getDiscussions());
      });

  Future<void> loadMore() => guard(() async {
        page.value += 1;
        final more = await _repository.getDiscussions(page: page.value);
        discussions.addAll(more);
      });

  Future<void> startDiscussion() async {
    final posted = await Get.toNamed(AppRoutes.communityCompose);
    // Refresh only when something was actually posted, so backing out of the
    // composer does not re-fetch for nothing.
    if (posted == true) await load();
  }

  Future<void> openThread(Discussion discussion) async {
    await Get.toNamed(AppRoutes.communityThread, arguments: discussion);
    // A reply changes the thread's comment count, so the list is refreshed on
    // the way back rather than showing a stale number.
    await load();
  }
}
