import '../models/expert_application.dart';

/// Sending an application to practise here, and seeing where it stands.
abstract class ExpertApplicationRepository {
  /// Sends one, with its two documents.
  ///
  /// The files travel with the form rather than after it: an application
  /// without the certificate and the ID cannot be reviewed, so a two-step
  /// upload would leave half-applications nobody can act on.
  ///
  /// Throws [ValidationException] carrying the server's own message when a
  /// field is refused, so the step that owns it can show it.
  Future<ExpertApplicationStatus> submit({
    required String fullName,
    required Set<ExpertField> fields,
    required Set<ExpertLanguage> languages,
    required int experienceYears,
    required String about,
    String portfolioUrl = '',
    String signatureQuote = '',
    String outsideSoothify = '',
    String licenceNumber = '',
    String insuranceProvider = '',
    required String certificationPath,
    required String identityPath,
  });

  /// Applications this account has sent, newest first. Empty when none.
  Future<List<ExpertApplicationStatus>> mine();
}
