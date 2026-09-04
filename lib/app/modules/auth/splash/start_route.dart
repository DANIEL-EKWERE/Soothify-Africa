import '../../../core/app_export.dart';
import '../../../data/models/user_role.dart';
import '../../../data/repositories/kyc_repository.dart';
import '../../../data/services/session_service.dart';

/// Decides the first real screen after the splash.
///
/// A plain function rather than a controller: the splash exists only to run
/// this once, and routing the app must not depend on GetX constructing a
/// controller whose screen never references it.
///
///   first launch     -> intro carousel
///   practitioner     -> practitioner dashboard (no designs yet)
///   signed out       -> sign up
///   KYC unfinished   -> KYC
///   otherwise        -> mood checker
///
/// If reading KYC state fails we send the user to the questionnaire rather
/// than past it: repeating a question is recoverable, silently skipping it
/// is not.
Future<String> resolveStartRoute({
  required SessionService session,
  required KycRepository kyc,
}) async {
  if (!PrefUtils().introSeen()) return AppRoutes.intro;

  switch (session.role.value) {
    case UserRole.practitioner:
      return AppRoutes.practitionerDashboard;
    case null:
      return AppRoutes.signup;
    case UserRole.user:
      try {
        return await kyc.isComplete() ? AppRoutes.shell : AppRoutes.kyc;
      } catch (e, s) {
        Log.e('could not read KYC state', error: e, stackTrace: s);
        return AppRoutes.kyc;
      }
  }
}
