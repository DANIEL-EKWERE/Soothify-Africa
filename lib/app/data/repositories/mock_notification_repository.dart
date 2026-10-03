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
      // The card `259:26851` opens with.
      AppNotification(
        id: '0',
        kind: NotificationKind.recommendation,
        title: 'Dr. Amaka recommended something for you',
        body: 'We\u2019ve prepared your weekly mental health tip to help you '
            'improve your mood.',
        avatarAsset: ImageConstant.imgAvatarFemale,
        unread: true,
        at: now.subtract(const Duration(minutes: 30)),
        filters: const {NotificationFilter.all, NotificationFilter.whatsNew},
      ),
      AppNotification(
        id: '1',
        kind: NotificationKind.social,
        actor: 'Kendrick',
        text: ' commented on your post...',
        avatarAsset: ImageConstant.imgAvatarMale,
        at: now.subtract(const Duration(minutes: 45)),
        filters: const {NotificationFilter.all, NotificationFilter.whatsNew},
      ),
      AppNotification(
        id: '2',
        kind: NotificationKind.social,
        actor: 'Paul',
        text: ' shared a new post',
        // The frame gives Kendrick and Paul the same portrait.
        avatarAsset: ImageConstant.imgAvatarMale,
        at: now.subtract(const Duration(days: 1)),
        filters: const {NotificationFilter.all, NotificationFilter.whatsNew},
      ),
      AppNotification(
        id: '3',
        kind: NotificationKind.reminder,
        title: 'Reminder',
        // The pill reads title + body, with the discipline bolded inside it.
        // Still "Yoga" — the rename covered the three section names, not the
        // practice.
        body: 'You have Yoga session today at 5:00pm',
        emphasis: 'Yoga',
        unread: true,
        at: now.subtract(const Duration(minutes: 5)),
        filters: const {NotificationFilter.all, NotificationFilter.sessions},
      ),
      AppNotification(
        id: '4',
        kind: NotificationKind.social,
        actor: 'Fatima',
        text: ' replied to your post',
        avatarAsset: ImageConstant.imgAvatarFemale,
        at: now.subtract(const Duration(hours: 1)),
        filters: const {NotificationFilter.all, NotificationFilter.whatsNew},
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
        filters: const {NotificationFilter.all, NotificationFilter.whatsNew},
      ),
      AppNotification(
        id: '6',
        kind: NotificationKind.plain,
        actor: 'John',
        text: ' commented on your post...',
        at: now.subtract(const Duration(days: 1)),
        filters: const {NotificationFilter.all, NotificationFilter.whatsNew},
      ),
      AppNotification(
        id: '7',
        kind: NotificationKind.action,
        text: 'New article posted',
        actionLabel: 'Read',
        at: now.subtract(const Duration(minutes: 7)),
        filters: const {NotificationFilter.all, NotificationFilter.whatsNew},
      ),
      // The booking rows — Figma `259:61271`, which draws one "Booking" and
      // four identical "Reminder" lines. Three is enough to show the shape
      // without repeating the same sentence down the screen.
      AppNotification(
        id: '8',
        kind: NotificationKind.booking,
        title: 'Booking',
        body: 'You have a Yoga session on 28 Sep 2026 at 5:00pm',
        emphasis: 'Yoga',
        unread: true,
        at: now.subtract(const Duration(minutes: 20)),
        filters: const {
          NotificationFilter.all,
          NotificationFilter.sessions,
        },
      ),
      AppNotification(
        id: '9',
        kind: NotificationKind.booking,
        title: 'Reminder',
        body: 'You have Yoga session today at 5:00pm',
        emphasis: 'Yoga',
        unread: true,
        at: now.subtract(const Duration(hours: 2)),
        filters: const {
          NotificationFilter.all,
          NotificationFilter.sessions,
        },
      ),
      AppNotification(
        id: '10',
        kind: NotificationKind.booking,
        title: 'Reminder',
        body: 'You have Pilates & Core session tomorrow at 7:00am',
        emphasis: 'Pilates & Core',
        at: now.subtract(const Duration(hours: 5)),
        filters: const {
          NotificationFilter.all,
          NotificationFilter.sessions,
        },
      ),
    ];
  }
}
