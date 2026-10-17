import '../../core/errors/app_exception.dart';
import '../../core/utils/logger.dart';
import 'kyc_repository.dart';

/// The onboarding questionnaire, on the device and then on the account.
///
/// The questionnaire is answered before anybody has an account — that is
/// the point of it, and asking somebody to sign up before they have been
/// asked what they are here for is the wrong way round. So the device holds
/// the answers and serves every read, and the server is told only once
/// there is an account to tell.
///
/// Reading from the server was what broke this: `/auth/kyc/` needs a bearer
/// token, so every answer saved during onboarding came back 401 and the app
/// announced that the session had expired to somebody who had never signed
/// in.
///
/// Nothing is ever read back over the local copy. A device that answered
/// the questionnaire yesterday holds the truth about it; the account may
/// hold nothing at all until [uploadToAccount] has run.
class SyncingKycRepository implements KycRepository {
  SyncingKycRepository(this._local, this._remote, {required this.signedIn});

  final KycRepository _local;
  final KycRepository _remote;

  /// Whether there is an account to write to.
  ///
  /// A function rather than a flag: this object is built once, early, and
  /// outlives the sign-up that changes the answer.
  ///
  /// It asks about the token, not about the session's role — role is chosen
  /// during onboarding, before any account exists, so a role-based check
  /// would call the server exactly when it cannot be called.
  final bool Function() signedIn;

  @override
  Future<Map<String, Set<String>>> savedAnswers() => _local.savedAnswers();

  @override
  Future<bool> isComplete() => _local.isComplete();

  @override
  Future<void> saveAnswers(Map<String, Set<String>> answers) async {
    // Saved first, and the caller is answered from this: an answer is
    // recorded the moment it is given, whatever the network is doing.
    await _local.saveAnswers(answers);
    await _tellTheServer(() => _remote.saveAnswers(answers));
  }

  @override
  Future<void> markComplete() async {
    await _local.markComplete();
    await _tellTheServer(_remote.markComplete);
  }

  /// Writes what the device holds onto the account that has just been made.
  ///
  /// Called after signing up and after signing in, which are the two
  /// moments an anonymous questionnaire acquires an owner. Sending the whole
  /// set rather than a diff is deliberate: the server merges a PATCH into
  /// what it holds, so this is safe to run twice and self-healing after a
  /// failed attempt.
  Future<void> uploadToAccount() async {
    if (!signedIn()) return;

    final answers = await _local.savedAnswers();
    if (answers.isNotEmpty) {
      await _tellTheServer(() => _remote.saveAnswers(answers));
    }
    if (await _local.isComplete()) {
      await _tellTheServer(_remote.markComplete);
    }
  }

  /// Best effort, always. The questionnaire is answered on the device; the
  /// server copy is for reading on another phone and for the team, and
  /// neither is worth interrupting somebody's onboarding over.
  Future<void> _tellTheServer(Future<void> Function() call) async {
    if (!signedIn()) return;
    try {
      await call();
    } on AppException catch (error) {
      Log.e('kyc not sent to the account yet', error: error);
    }
  }
}
