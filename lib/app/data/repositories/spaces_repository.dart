import '../models/space_listing.dart';

/// Studios, and the Passport waitlist the plan card collects.
abstract class SpacesRepository {
  /// ?category=&q=&lat=&lng= — the chips, the search field and the phone's
  /// own position, which the server turns into a distance.
  Future<List<SpaceListing>> spaces({
    String category = 'all',
    String query = '',
    double? latitude,
    double? longitude,
  });

  Future<SpaceListing?> space(String id);

  /// Reserve a place on the Passport waitlist.
  ///
  /// True when this is a new entry, false when the address was already on
  /// the list -- which is not an error and should be said kindly.
  Future<bool> joinPassportWaitlist(String email, {String city = '', String source = ''});
}
