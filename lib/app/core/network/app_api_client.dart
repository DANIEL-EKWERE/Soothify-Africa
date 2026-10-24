import 'package:get/get.dart';

import '../../data/services/session_service.dart';
import '../../routes/app_routes.dart';
import '../utils/feedback_utils.dart';
import '../utils/pref_utils.dart';
import 'api_client.dart';

/// The app's one [ApiClient], wired to where this app keeps its credentials.
///
/// Built here rather than at each call site because it was built twice —
/// in `main()` and in [InitialBindings] — and both passed only the access
/// token. With no `refreshToken` callback, [ApiClient] read the refresh
/// token as empty and gave up at the first line of its refresh, so every
/// session died thirty minutes after sign-in and said so. With no
/// `onSignedOut`, nothing told the rest of the app the session was over,
/// which is how Home could show the guest header while Profile still showed
/// a signed-in user.
ApiClient buildApiClient() => ApiClient(
      accessToken: () => PrefUtils().accessToken,
      refreshToken: () => PrefUtils().refreshToken,
      onTokens: (access, refresh) =>
          PrefUtils().setTokens(access: access, refresh: refresh),
      onSignedOut: expireSession,
    );

/// Whether the expiry is already being handled, so the message is said once
/// and the clear-out does not recurse.
///
/// Six screens can meet the dead session at the same moment, and each one
/// would otherwise raise its own snackbar.
bool _expiring = false;

/// The server refused the refresh token: the session is over.
///
/// Clears the credentials, says so once, and puts the user on the sign-in
/// screen — a dead session is not browsable, and leaving them on a screen
/// whose every request now fails is worse than asking them to sign in.
Future<void> expireSession() async {
  if (_expiring) return;
  _expiring = true;
  try {
    if (Get.isRegistered<SessionService>()) {
      await Get.find<SessionService>().expire();
    } else {
      await PrefUtils().clearSession();
    }
    AppFeedback.info('Your session has ended. Please sign in again.');
    // Out to sign-in, and nothing of the signed-in app left behind it: the
    // screens underneath were built for a user who is no longer there, and
    // Back from the sign-in screen must not walk into them.
    if (Get.currentRoute != AppRoutes.signin) {
      Get.offAllNamed(AppRoutes.signin);
    }
  } finally {
    _expiring = false;
  }
}
