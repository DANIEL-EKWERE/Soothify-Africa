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
///   guest            -> same as a signed-in user; the app is usable without
///                       an account, and Profile offers sign-up when wanted
///   KYC unfinished   -> KYC
///   otherwise        -> the shell
///
/// If reading KYC state fails we send the user to the questionnaire rather
/// than past it: repeating a question is recoverable, silently skipping it
/// is not.
Future<String> resolveStartRoute({
  required SessionService session,
  required KycRepository kyc,
}) async {
  if (!PrefUtils().introSeen()) return AppRoutes.intro;

  if (session.role.value == UserRole.practitioner) {
    return AppRoutes.practitionerDashboard;
  }

  // A null role is a guest, not a locked-out user. Onboarding already runs
  // intro -> personalize -> language -> KYC -> shell without ever asking for
  // an account, so sending guests to sign-up on the *next* launch would lock
  // them out of an app they had already been using.
  try {
    return await kyc.isComplete() ? AppRoutes.shell : AppRoutes.kyc;
  } catch (e, s) {
    Log.e('could not read KYC state', error: e, stackTrace: s);
    return AppRoutes.kyc;
  }
}
