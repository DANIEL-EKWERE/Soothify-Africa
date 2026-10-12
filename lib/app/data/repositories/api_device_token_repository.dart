import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/pref_utils.dart';
import 'device_token_repository.dart';

/// Registers this install with the Django API.
///
/// `POST /api/v1/notifications/devices/` with `{token, platform}`, which
/// `update_or_create`s on the token — so re-registering is how a reinstall
/// or a handed-on phone gets re-pointed at the right account, not an error.
///
/// The endpoint is `IsAuthenticated`. The app's sign-in does not yet reach
/// the backend, so there is usually no JWT and this skips rather than
/// throwing: push still works end to end on the device, and registration
/// starts happening by itself the day auth lands.
class ApiDeviceTokenRepository implements DeviceTokenRepository {
  ApiDeviceTokenRepository(this._api);

  final ApiClient _api;

  static const _path = '/notifications/devices/';

  /// The model's `platform` choices are lowercase — `android`, `ios`, `web`.
  /// Anything else is a 400.
  static String wirePlatform(String platform) => platform.toLowerCase();

  @override
  String get lastRegistered => PrefUtils().deviceToken;

  @override
  Future<void> register({
    required String token,
    required String platform,
    required String deviceModel,
    required String appVersion,
  }) async {
    // The server stores neither the model nor the app version — PushDevice
    // holds only the token, the platform and when it was last seen. They are
    // taken and logged so the caller's contract does not have to differ per
    // backend.
    Log.d('Registering $platform ($deviceModel, $appVersion) for push');

    if (PrefUtils().accessToken.isEmpty) {
      // Nothing to authenticate with. Keep the token locally so the next
      // launch after signing in sends it.
      Log.d('No session yet; holding the push token locally.');
      await PrefUtils().setDeviceToken('');
      return;
    }

    try {
      await _api.post(
        _path,
        body: {'token': token, 'platform': wirePlatform(platform)},
      );
      // Only now: a token recorded as sent that never arrived would never be
      // retried, because PushService skips an unchanged one.
      await PrefUtils().setDeviceToken(token);
    } on AppException catch (e) {
      // Registration is not worth failing a launch over. Leaving the stored
      // token empty is what schedules the retry.
      Log.e('Could not register for push', error: e);
    }
  }

  /// Stops pushes to this install — `DELETE` with the same token.
  ///
  /// Called on sign-out: the account is gone from this phone, so the
  /// reminders belonging to it should stop arriving on it.
  Future<void> unregister() async {
    final token = PrefUtils().deviceToken;
    if (token.isEmpty || PrefUtils().accessToken.isEmpty) return;
    try {
      await _api.delete(_path, body: {'token': token});
    } on AppException catch (e) {
      Log.e('Could not unregister this device', error: e);
    }
    // Cleared either way: the next sign-in must re-register rather than
    // assume the server still knows about this phone.
    await PrefUtils().setDeviceToken('');
  }
}
