import '../models/signed_in_user.dart';

/// Signing in, registering, and getting back in after forgetting a password.
///
/// An interface so the controllers can be tested without a network or a
/// provider SDK, and so the local stand-in can be swapped for the
/// Django-backed one in a single binding.
abstract class AuthRepository {
  /// Signs in with Google. Null means the user backed out of the provider's
  /// own sheet — a decision, not a failure, and nothing should be said
  /// about it.
  ///
  /// Throws an [AppException] if the provider refuses, the server rejects
  /// the token, or the network is unreachable.
  Future<SignedInUser?> signInWithGoogle();

  Future<SignedInUser?> signInWithApple();

  /// Opens an account. Throws [ValidationException] carrying the server's
  /// own message when the address is taken or the password is too weak —
  /// those are the two the form has to show.
  Future<SignedInUser> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<SignedInUser> signIn({
    required String email,
    required String password,
  });

  /// Gives up the session. The refresh token goes back to the server so it
  /// can be retired; the tokens on the device are forgotten either way.
  Future<void> signOut();

  /// Whether an address can still be registered, so the form can say
  /// "already taken" before asking for a password.
  Future<bool> emailAvailable(String email);

  /// Starts a reset: the server emails a six-digit code.
  ///
  /// Answers the same whether or not the address has an account. For a
  /// mental-health app, confirming who is a member is a disclosure worth
  /// more than a clearer error message.
  Future<void> requestPasswordReset(String email);

  /// Closes the account and erases what is personal.
  ///
  /// [confirm] is the password, or — for an account opened with Google or
  /// Apple, which has none — the email address. The server checks it: this
  /// is the one action in the app that cannot be taken back, and a phone
  /// left unlocked on a table should not be enough to do it.
  Future<void> deleteAccount(String confirm);

  /// Finishes a reset, and signs them in — they have just proved they hold
  /// the address and chosen a password, so asking them to type it again is
  /// friction for its own sake.
  Future<SignedInUser> confirmPasswordReset({
    required String email,
    required String code,
    required String password,
  });
}
