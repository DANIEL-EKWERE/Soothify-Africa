import '../../core/utils/image_constant.dart';
import '../models/app_notification.dart';
import 'notification_repository.dart';

/// Local stand-in for the Django API, which does not exist yet.
///
/// The entries are the frame's own, in its order — that is what makes the
/// screen's mix of shapes visible while there is nothing real to show.
/// Timestamps are offsets from "now" rather than the frame's fixed strings, so
/// the list ages the way a real feed does.
class MockNotificationRepository implements NotificationRepository {
  MockNotificationRepository({DateTime Function()? now})
      : _now = now ?? DateTime.now;

  /// Overridable so "now" can be pinned in tests — a screen full of relative
  /// timestamps drifts out of sync with any golden that captured it.
  final DateTime Function() _now;

  static const _latency = Duration(milliseconds: 400);

  @override
  Future<List<AppNotification>> feed() async {
    await Future<void>.delayed(_latency);
    final now = _now();
    return [
      AppNotification(
        id: '1',
        kind: NotificationKind.social,
        actor: 'Kendrick',
        text: ' commented on your post...',
        avatarAsset: ImageConstant.imgAvatarMale,
        at: now.subtract(const Duration(minutes: 45)),
        filters: const {NotificationFilter.all, NotificationFilter.myPost},
      ),
      AppNotification(
        id: '2',
        kind: NotificationKind.social,
        actor: 'Paul',
        text: ' shared a new post',
        // The frame gives Kendrick and Paul the same portrait.
        avatarAsset: ImageConstant.imgAvatarMale,
        at: now.subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: '3',
        kind: NotificationKind.reminder,
        title: 'Reminder',
        actor: 'You have ',
        // Bold in the frame, and still "Yoga" there — the rename covered the
        // three section names, not the practice.
        text: 'Yoga',
        body: ' session today at 5:00pm',
        iconAsset: ImageConstant.icReminder,
        unread: true,
        at: now.subtract(const Duration(minutes: 5)),
      ),
      AppNotification(
        id: '4',
        kind: NotificationKind.social,
        actor: 'Fatima',
        text: ' replied to your post',
        avatarAsset: ImageConstant.imgAvatarFemale,
        at: now.subtract(const Duration(hours: 1)),
        filters: const {NotificationFilter.all, NotificationFilter.myPost},
      ),
      AppNotification(
        id: '5',
        kind: NotificationKind.digest,
        title: 'Your Weekly Mindful Quotes',
        body: 'We’ve prepared your weekly mental health tip\n'
            'to help you improve your mood.',
        iconAsset: ImageConstant.icHeartFilled,
        unread: true,
        at: now.subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: '6',
        kind: NotificationKind.plain,
        actor: 'John',
        text: ' commented on your post...',
        at: now.subtract(const Duration(days: 1)),
        filters: const {NotificationFilter.all, NotificationFilter.mentions},
      ),
      AppNotification(
        id: '7',
        kind: NotificationKind.action,
        text: 'New article posted',
        actionLabel: 'Read',
        at: now.subtract(const Duration(minutes: 7)),
      ),
    ];
  }
}
