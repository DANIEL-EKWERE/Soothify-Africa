/// Where this device's push token goes.
///
/// A token identifies one install, not one account: it changes on reinstall,
/// on a data clear, and whenever Firebase decides to rotate it. The server
/// needs every version of it, which is why [register] is called on refresh
/// as well as at startup.
abstract class DeviceTokenRepository {
  /// Hands the token to the backend, along with enough about the device to
  /// tell a stale registration from a live one.
  Future<void> register({
    required String token,
    required String platform,
    required String deviceModel,
    required String appVersion,
  });

  /// The token last registered, or empty. Lets a repeat registration of an
  /// unchanged token be skipped.
  String get lastRegistered;
}
