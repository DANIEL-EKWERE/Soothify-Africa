import 'package:get/get.dart';

import '../../core/utils/pref_utils.dart';
import '../models/user_role.dart';

/// Holds who is using the app and in which role.
///
/// A [GetxService] rather than a controller because it must outlive every
/// route — routing and bindings both read from it.
class SessionService extends GetxService {
  final Rxn<UserRole> role = Rxn<UserRole>();

  bool get isSignedIn => role.value != null;
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

  Future<void> signOut() async {
    role.value = null;
    await PrefUtils().clearSession();
  }
}
