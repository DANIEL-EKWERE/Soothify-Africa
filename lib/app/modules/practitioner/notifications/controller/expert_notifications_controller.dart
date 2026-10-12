import '../../../../core/app_export.dart';
import '../../../../data/models/expert_notification.dart';

/// Backs the expert's notification feed.
///
/// The rows are fixed for now — nothing schedules sessions on this side yet,
/// so these are the frame's own, not an empty list pretending to be real.
class ExpertNotificationsController extends GetxController {
  final Rx<ExpertNotificationFilter> filter =
      ExpertNotificationFilter.all.obs;

  static const _all = [
    ExpertNotification(
      kind: ExpertNotificationKind.booking,
      body: 'You have a Yoga session on 28 Sep 2026 at 5:00pm',
      emphasis: 'Yoga',
    ),
    ExpertNotification(
      kind: ExpertNotificationKind.reminder,
      body: 'You have Yoga session today at 5:00pm',
      emphasis: 'Yoga',
    ),
    ExpertNotification(
      kind: ExpertNotificationKind.reminder,
      body: 'You have Yoga session today at 5:00pm',
      emphasis: 'Yoga',
    ),
    ExpertNotification(
      kind: ExpertNotificationKind.reminder,
      body: 'You have Yoga session today at 5:00pm',
      emphasis: 'Yoga',
    ),
  ];

  List<ExpertNotification> get visible =>
      _all.where((n) => n.matches(filter.value)).toList();

  void select(ExpertNotificationFilter value) => filter.value = value;
}
