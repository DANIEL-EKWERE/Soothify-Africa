/// The Corporate enquiry the Plans screen's third card opens.
abstract class CorporateRepository {
  /// Send one. The four named fields are what the team needs to answer it;
  /// the rest are welcome but optional.
  Future<void> send({
    required String company,
    required String contactName,
    required String email,
    required String phone,
    String employees = '',
    String services = '',
    String notes = '',
  });
}
