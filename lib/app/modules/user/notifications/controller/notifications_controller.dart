import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/app_notification.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/article.dart';
import '../../../../data/models/coach.dart';
import '../../../../data/models/session_invite.dart';
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

  /// The frame gives the article row a "Read" link.
  ///
  /// The notification names no particular article — it reads "New article
  /// posted" — and the file holds two, so this opens the Pilates & Core one.
  /// When the feed carries an id, it goes in the arguments instead.
  /// A session row under the Sessions chip — the waiting room, then the call.
  ///
  /// Nothing schedules sessions yet, so who the session is with and when it
  /// runs come from the notification's own copy: the discipline it bolds, and
  /// the hour at the end of its line.
  void openSession(AppNotification notification) {
    Get.toNamed(
      AppRoutes.clientJoining,
      arguments: SessionInvite(
        expertName: Coach.sample.name.split(' ').first,
        service: notification.emphasis.isEmpty
            ? '1-on-1 Therapy'
            : '1-on-1 ${notification.emphasis}',
        time: _timeIn(notification.body),
        date: DateFormat('MMM d yyyy').format(notification.at),
      ),
    );
  }

  /// The hour at the end of "You have a Yoga session on 28 Sep 2026 at
  /// 5:00pm". Falls back to the frame's own range when there is none.
  static String _timeIn(String line) {
    final match = RegExp(r'(\d{1,2}:\d{2}\s*[ap]m)', caseSensitive: false)
        .firstMatch(line);
    return match?.group(1) ?? '10:00 AM - 11:00 AM';
  }

  void openAction(AppNotification notification) {
    if (notification.kind == NotificationKind.breathe) {
      Get.toNamed(AppRoutes.breathe);
      return;
    }
    Get.toNamed(AppRoutes.article, arguments: Article.core);
  }
}
