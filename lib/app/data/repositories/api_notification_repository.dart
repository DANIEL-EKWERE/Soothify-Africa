import '../../core/network/api_client.dart';
import '../models/app_notification.dart';
import 'notification_repository.dart';

/// The notification feed, from `/api/v1/notifications/`.
///
/// One request for the whole feed; the chips filter what is already here
/// rather than asking again, which is how the screen behaves and keeps
/// switching between them instant.
class ApiNotificationRepository implements NotificationRepository {
  ApiNotificationRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<AppNotification>> feed() async {
    final rows = await _api.getList('/notifications/');
    return rows.map(AppNotification.fromJson).toList();
  }

  @override
  Future<int> unreadCount() async {
    final body = await _api.get('/notifications/unread/');
    return body['unread'] as int? ?? 0;
  }

  @override
  Future<void> markRead({String? id}) async {
    // One row, or the lot. Both are the same endpoint on the server, which
    // is why there is one method here rather than two.
    await _api.post(id == null ? '/notifications/read/' : '/notifications/$id/read/');
  }

  @override
  Future<Map<String, bool>> preferences() async {
    final body = await _api.get('/notifications/preferences/');
    return {
      for (final entry in body.entries)
        if (entry.value is bool) entry.key: entry.value as bool,
    };
  }

  @override
  Future<void> savePreference(String key, bool value) async {
    await _api.patch('/notifications/preferences/', body: {key: value});
  }
}
