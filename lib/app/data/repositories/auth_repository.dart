import '../models/user_role.dart';

/// Signing in, however it is done.
///
/// An interface so the controllers can be tested without a network or a
/// provider SDK, and so the local stand-in that exists today can be swapped
/// for the Django-backed one in a single binding.
abstract class AuthRepository {
  /// Signs in with Google and returns the role to establish.
  ///
  /// Throws an [AppException] if the provider refuses, the server rejects
  /// the token, or the network is unreachable. Returns null if the user
  /// backed out of the provider's own sheet — a cancellation is not a
  /// failure and must not raise an error at them.
  Future<UserRole?> signInWithGoogle();

  Future<UserRole?> signInWithApple();
}
