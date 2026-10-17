import 'corporate_repository.dart';

/// Corporate enquiries without a server.
///
/// Accepts the form and does nothing with it. The success screen is shown
/// either way, which is honest only because the screen says the team will
/// be in touch -- when this is bound, nobody has been told.
class MockCorporateRepository implements CorporateRepository {
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
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
