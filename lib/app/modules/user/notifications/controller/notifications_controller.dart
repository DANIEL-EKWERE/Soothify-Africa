import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/app_notification.dart';
import '../../../../data/repositories/notification_repository.dart';

/// Backs the notification feed — Figma "Notification" (`176:24737`).
class NotificationsController extends BaseController {
  NotificationsController(this._repository, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final NotificationRepository _repository;

  /// Overridable so "now" can be pinned in tests: every row carries a relative
  /// timestamp, so a golden recorded against the wall clock goes stale.
  final DateTime Function() _now;

  final RxList<AppNotification> all = <AppNotification>[].obs;

  final Rx<NotificationFilter> filter = NotificationFilter.all.obs;

  DateTime get now => _now();

  /// What the chosen chip leaves on screen.
  List<AppNotification> get visible =>
      all.where((n) => n.filters.contains(filter.value)).toList();

  int get unreadCount => all.where((n) => n.unread).length;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
        all.assignAll(await _repository.feed());
      });

  void select(NotificationFilter value) => filter.value = value;

  /// The frame gives the article row a "Read" link. Nothing behind it yet —
  /// the Article frame is in the file but not built.
  void openAction(AppNotification notification) =>
      AppFeedback.info('Articles are not built yet.');
}
