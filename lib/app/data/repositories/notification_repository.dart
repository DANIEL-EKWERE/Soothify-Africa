import '../models/app_notification.dart';

/// The contract the notification screen codes against.
abstract class NotificationRepository {
  /// Newest first.
  Future<List<AppNotification>> feed();
}
