import '../models/expert_application.dart';
import 'expert_application_repository.dart';

/// Applications without a server.
///
/// Accepts the form and keeps it in memory for the length of the run, so the
/// acknowledgement and the "being reviewed" line can both be seen. Nothing
/// is sent anywhere, and the acknowledgement promises only a review — which
/// is as true here as it is with a server behind it.
class MockExpertApplicationRepository implements ExpertApplicationRepository {
  static const _latency = Duration(milliseconds: 500);

  final List<ExpertApplicationStatus> _sent = [];

  @override
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
  }) async {
    await Future<void>.delayed(_latency);
    final application = ExpertApplicationStatus(
      id: '${_sent.length + 1}',
      status: 'submitted',
      statusLabel: 'Submitted',
      sentAt: DateTime.now(),
      fields: fields,
    );
    _sent.add(application);
    return application;
  }

  @override
  Future<List<ExpertApplicationStatus>> mine() async {
    await Future<void>.delayed(_latency);
    return List.unmodifiable(_sent.reversed);
  }
}
