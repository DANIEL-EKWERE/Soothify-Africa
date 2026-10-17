import '../models/app_notification.dart';

/// The contract the notification screens code against.
abstract class NotificationRepository {
  /// Newest first.
  Future<List<AppNotification>> feed();

  /// How many are unread, for the dot on the bell.
  ///
  /// Asked for rather than counted from [feed]: the bell is on every screen
  /// and the feed is a page of rows, so counting what happens to be loaded
  /// would under-report as soon as there is more than one page.
  Future<int> unreadCount();

  /// Marks one read, or the whole feed when no id is given.
  Future<void> markRead({String? id});

  /// The four switches, keyed by [NotificationPreference.key].
  Future<Map<String, bool>> preferences();

  /// Saves one switch. Sent one at a time because that is how they are
  /// pressed, and a partial save of four is worse than a failed save of one.
  Future<void> savePreference(String key, bool value);
}
