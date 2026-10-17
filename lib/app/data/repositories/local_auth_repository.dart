import '../../core/errors/app_exception.dart';
import '../models/signed_in_user.dart';
import '../models/user_role.dart';
import 'auth_repository.dart';

/// Accounts without a server.
///
/// Accepts anything that looks like an address and a long enough password,
/// and signs the person in as themselves. It exists so the app can be run
/// and demonstrated end to end on a machine with no backend — not as a
/// security measure, which is why nothing here is remembered between
/// launches and nothing claims to have been verified.
class LocalAuthRepository implements AuthRepository {
  static const _latency = Duration(milliseconds: 400);

  /// Addresses this build has "registered", so a second sign-up with the
  /// same one behaves the way the real one does.
  final Set<String> _taken = <String>{};

  @override
  Future<SignedInUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);
    final address = email.trim().toLowerCase();
    if (_taken.contains(address)) {
      throw const ValidationException('That email already has an account.');
    }
    _taken.add(address);
    return SignedInUser(
      role: UserRole.user,
      fullName: fullName.trim(),
      email: address,
    );
  }

  @override
  Future<SignedInUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);
    if (password.length < 6) {
      throw const ValidationException(
        'You entered an incorrect password. Please try again',
      );
    }
    return SignedInUser(role: UserRole.user, email: email.trim().toLowerCase());
  }

  @override
  Future<void> signOut() async => Future<void>.delayed(_latency);

  @override
  Future<void> deleteAccount(String confirm) async {
    await Future<void>.delayed(_latency);
    // Nothing to delete, and nothing is claimed to have been.
    throw const UnknownException('Deleting an account needs the server.');
  }

  @override
  Future<bool> emailAvailable(String email) async {
    await Future<void>.delayed(_latency);
    return !_taken.contains(email.trim().toLowerCase());
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await Future<void>.delayed(_latency);
    // No mail is sent, and the screen must not imply one was. The caller
    // shows the server's own wording, which is deliberately non-committal.
  }

  @override
  Future<SignedInUser> confirmPasswordReset({
    required String email,
    required String code,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);
    // Nothing issued the code, so nothing can check it. Refused rather than
    // accepted: a stand-in that waves through a reset is worse than one
    // that admits it cannot do them.
    throw const ValidationException(
      'Password resets need the server. Sign in with your password instead.',
    );
  }

  @override
  Future<SignedInUser?> signInWithGoogle() async {
    await Future<void>.delayed(_latency);
    throw const UnknownException('Google sign-in needs the server.');
  }

  @override
  Future<SignedInUser?> signInWithApple() async {
    await Future<void>.delayed(_latency);
    throw const UnknownException('Apple sign-in needs the server.');
  }
}
