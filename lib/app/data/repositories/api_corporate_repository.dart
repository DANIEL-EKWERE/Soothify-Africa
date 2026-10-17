import '../../core/network/api_client.dart';
import 'corporate_repository.dart';

/// Corporate enquiries against `/api/v1/corporate/enquiries/`.
class ApiCorporateRepository implements CorporateRepository {
  ApiCorporateRepository(this._api);

  final ApiClient _api;

  @override
  Future<void> send({
    required String company,
    required String contactName,
    required String email,
    required String phone,
    String employees = '',
    String services = '',
    String notes = '',
  }) async {
    await _api.post('/corporate/enquiries/', body: {
      'company': company.trim(),
      'contact_name': contactName.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'employees': employees.trim(),
      'services': services.trim(),
      'notes': notes.trim(),
    });
  }
}
