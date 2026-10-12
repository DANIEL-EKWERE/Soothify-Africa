import 'package:get/get.dart';

import '../../core/utils/pref_utils.dart';
import '../models/user_role.dart';
import '../repositories/api_device_token_repository.dart';
import '../repositories/device_token_repository.dart';

/// Holds who is using the app and in which role.
///
/// A [GetxService] rather than a controller because it must outlive every
/// route — routing and bindings both read from it.
class SessionService extends GetxService {
  final Rxn<UserRole> role = Rxn<UserRole>();

  bool get isSignedIn => role.value != null;

  /// Browsing without an account. The app is fully usable this way; only
  /// things that need to persist across devices ask for sign-up.
  bool get isGuest => role.value == null;
  bool get isPractitioner => role.value == UserRole.practitioner;

  Future<SessionService> init() async {
    // Idempotent; guarantees preferences are loaded even if this service
    // is constructed before main() initialises them (as in tests).
    await PrefUtils().init();
    role.value = UserRole.fromKey(PrefUtils().getUserRole());
    return this;
  }

  Future<void> setRole(UserRole value) async {
    role.value = value;
    await PrefUtils().setUserRole(value.key);
  }

  /// Signing out returns to guest browsing rather than to the sign-up wall —
  /// the same state a user who never registered is in.
  Future<void> signOut() async {
    // Before the credentials go: unregistering needs the very token it is
    // about to clear. Pushes aimed at the account that just left must not
    // keep arriving on this phone.
    final tokens = Get.isRegistered<DeviceTokenRepository>()
        ? Get.find<DeviceTokenRepository>()
        : null;
    if (tokens is ApiDeviceTokenRepository) await tokens.unregister();

    role.value = null;
    await PrefUtils().clearSession();
  }
}
