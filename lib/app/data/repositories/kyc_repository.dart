/// Stores the KYC questionnaire's answers, and whether it was finished.
///
/// Answers are keyed by question id, each holding the chosen option values —
/// one for a single-choice question, several for a multi-select. That shape
/// matches what the Django API will accept and survives adding or reordering
/// questions.
abstract class KycRepository {
  Future<Map<String, Set<String>>> savedAnswers();

  Future<void> saveAnswers(Map<String, Set<String>> answers);

  /// Drives whether splash sends the user into the questionnaire.
  Future<bool> isComplete();

  Future<void> markComplete();
}
