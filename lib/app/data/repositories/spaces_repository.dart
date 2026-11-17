import '../models/passport_reservation.dart';
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

  // ----------------------------------------------------- the Passport flow
  //
  // The member's half of the studio loop. A reservation made here is what
  // the studio partner sees on its roster, and the code it carries is what
  // their front desk verifies.

  /// The Passport classes a studio still has ahead of it.
  Future<List<StudioSession>> sessions(String spaceId);

  /// Take a place, against this period's allowance.
  ///
  /// Returns the place that is now held. Reserving the same class twice
  /// returns the first one rather than taking a second mat, so a retry whose
  /// response was lost is safe.
  Future<PassportReservation> reserve(int sessionId);

  /// Everything still ahead of the member — the Hub's own list.
  Future<List<PassportReservation>> reservations();

  /// Give a place back. The class returns to the allowance.
  Future<PassportReservation> cancelReservation(int reservationId);
}
