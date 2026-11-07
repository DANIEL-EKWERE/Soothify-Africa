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
///   email unconfirmed-> the code screen, for an account that has one
///   practitioner     -> practitioner dashboard (no designs yet)
///   guest            -> same as a signed-in user; the app is usable without
///                       an account, and Profile offers sign-up when wanted
///   KYC unfinished   -> KYC, unless the intro carousel's Skip was used
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

  // An account that owes us a confirmation code goes back to the screen
  // asking for it, whatever its role -- a studio and a practitioner own an
  // address the same way a member does.
  //
  // Guarded by `hasAccount`, not by the role: a role is chosen during
  // onboarding before anybody registers, and a guest has no address to
  // confirm. The flag defaults to false, so an install from before
  // verification existed is unaffected.
  if (session.hasAccount && PrefUtils().emailUnverified()) {
    return AppRoutes.verifyEmail;
  }

  if (session.role.value == UserRole.practitioner) {
    return AppRoutes.practitionerDashboard;
  }

  // A studio has no member app behind it — no library, no questionnaire —
  // so the portal is where its launch ends, before the KYC check below.
  if (session.role.value == UserRole.partner) {
    return AppRoutes.partnerPortal;
  }

  // A null role is a guest, not a locked-out user. Onboarding already runs
  // intro -> personalize -> language -> KYC -> shell without ever asking for
  // an account, so sending guests to sign-up on the *next* launch would lock
  // them out of an app they had already been using.
  try {
    if (await kyc.isComplete()) return AppRoutes.shell;
    // Skip has to survive a relaunch. Sending someone back to the
    // questionnaire they declined is the app overruling them.
    return PrefUtils().onboardingSkipped() ? AppRoutes.shell : AppRoutes.kyc;
  } catch (e, s) {
    Log.e('could not read KYC state', error: e, stackTrace: s);
    return AppRoutes.kyc;
  }
}
