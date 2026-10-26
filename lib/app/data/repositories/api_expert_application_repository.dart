import '../../core/network/api_client.dart';
import '../models/expert_application.dart';
import 'expert_application_repository.dart';

/// Applications against `/api/v1/experts/applications/`.
class ApiExpertApplicationRepository implements ExpertApplicationRepository {
  ApiExpertApplicationRepository(this._api);

  final ApiClient _api;

  static const _path = '/experts/applications/';

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
    final body = await _api.upload(
      _path,
      fields: {
        'full_name': fullName.trim(),
        'experience_years': '$experienceYears',
        'bio': about.trim(),
        if (portfolioUrl.trim().isNotEmpty) 'portfolio_url': portfolioUrl.trim(),
        if (signatureQuote.trim().isNotEmpty)
          'signature_quote': signatureQuote.trim(),
        if (outsideSoothify.trim().isNotEmpty)
          'outside_soothify': outsideSoothify.trim(),
        if (licenceNumber.trim().isNotEmpty)
          'licence_number': licenceNumber.trim(),
        if (insuranceProvider.trim().isNotEmpty)
          'insurance_provider': insuranceProvider.trim(),
      },
      // Repeated keys: a multipart form has no nesting, and the server reads
      // these with `getlist`. Sent as the server's own keys, not the frame's
      // labels -- "Certified Yoga Instructor" is not a discipline.
      listFields: {
        'disciplines': fields.map((f) => f.key).toList(),
        'languages': languages.map((l) => l.key).toList(),
      },
      files: {
        'certification': certificationPath,
        'identity': identityPath,
      },
    );
    return ExpertApplicationStatus.fromJson(body);
  }

  @override
  Future<List<ExpertApplicationStatus>> mine() async {
    final rows = await _api.getList(_path);
    final applications = rows.map(ExpertApplicationStatus.fromJson).toList()
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
    return applications;
  }
}
