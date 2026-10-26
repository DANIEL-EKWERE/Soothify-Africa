import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/expert_notification.dart';
import '../../../../data/repositories/notification_repository.dart';

/// Backs the expert's notification feed.
///
/// Reads the server. The rows here used to be four of the design's own,
/// hard-coded -- which meant a practitioner saw the same three "Yoga
/// session today at 5:00pm" lines forever, and never saw a booking that
/// had actually been made.
class ExpertNotificationsController extends BaseController {
  ExpertNotificationsController(this._repository);

  final NotificationRepository _repository;

  final Rx<ExpertNotificationFilter> filter =
      ExpertNotificationFilter.all.obs;

  final RxList<ExpertNotification> all = <ExpertNotification>[].obs;

  /// Whether the first load has come back, so an empty list can tell the
  /// difference between "nothing yet" and "still asking".
  final RxBool loaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final rows = await guard(() => _repository.feed(), showFeedback: false);
    if (rows != null) {
      all.assignAll(rows.map(ExpertNotification.fromFeed).toList());
    }
    loaded.value = true;
  }

  List<ExpertNotification> get visible =>
      all.where((n) => n.matches(filter.value)).toList();

  void select(ExpertNotificationFilter value) => filter.value = value;

  /// Tapping a row. Marks it read so the dot goes; there is nowhere to send
  /// the practitioner yet, since the feed carries no target of its own.
  Future<void> open(ExpertNotification row) async {
    if (!row.unread || row.id.isEmpty) return;
    final at = all.indexWhere((n) => n.id == row.id);
    if (at >= 0) {
      all[at] = ExpertNotification(
        id: row.id,
        kind: row.kind,
        body: row.body,
        emphasis: row.emphasis,
        unread: false,
      );
    }
    await guard(
      () async {
        await _repository.markRead(id: row.id);
        return true;
      },
      // A dot that comes back on the next load is the worst this can do.
      showFeedback: false,
    );
  }
}
