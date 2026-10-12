import '../../core/utils/logger.dart';
import '../../core/utils/pref_utils.dart';
import 'device_token_repository.dart';

/// Keeps the token on the device until there is somewhere to send it.
///
/// There is no API yet — every repository in this app is still local or
/// mock — so registering means storing it and logging it, which is also what
/// makes a push testable today: the token printed here is what you paste
/// into the Firebase console to send one.
///
/// When the Django endpoint exists, only [InitialBindings] changes: a second
/// implementation posts the same four fields and this one stays as the
/// offline fallback.
class LocalDeviceTokenRepository implements DeviceTokenRepository {
  @override
  String get lastRegistered => PrefUtils().deviceToken;

  @override
  Future<void> register({
    required String token,
    required String platform,
    required String deviceModel,
    required String appVersion,
  }) async {
    Log.d('FCM token for $platform ($deviceModel, $appVersion): $token');
    await PrefUtils().setDeviceToken(token);
  }
}
