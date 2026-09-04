
import '../../../../core/app_export.dart';
import '../../../../data/models/user_role.dart';
import '../../../../data/services/session_service.dart';

/// Temporary entry point standing in for real authentication.
/// Replace with the designed sign-in flow once it exists.
class RoleSelectController extends GetxController {
  RoleSelectController(this._session);

  final SessionService _session;

  Future<void> choose(UserRole role) async {
    await _session.setRole(role);
    Get.offAllNamed(
      role == UserRole.practitioner
          ? AppRoutes.practitionerDashboard
          : AppRoutes.kyc,
    );
  }
}
