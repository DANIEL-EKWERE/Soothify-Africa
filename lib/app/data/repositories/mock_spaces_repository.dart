import '../models/passport_reservation.dart';
import '../models/space_listing.dart';
import '../models/wellness_space.dart';
import 'spaces_repository.dart';

/// Studios without a server: the three the design draws, filtered the same
/// way the server filters them so the screen behaves identically.
class MockSpacesRepository implements SpacesRepository {
  MockSpacesRepository({DateTime Function()? now}) : _now = now ?? DateTime.now;

  /// The clock the sample classes are dated from.
  ///
  /// Injected by the tests. Without it the sessions sit a day after whenever
  /// they were asked for, so a golden of this screen recorded the date it
  /// was taken and failed every day after -- which is exactly what it did.
  final DateTime Function() _now;

  static const _latency = Duration(milliseconds: 300);

  @override
  Future<List<SpaceListing>> spaces({
    String category = 'all',
    String query = '',
    double? latitude,
    double? longitude,
  }) async {
    await Future<void>.delayed(_latency);
    final term = query.trim().toLowerCase();

    return WellnessSpace.sample
        .where((s) => category == 'all' || s.category.name == category)
        .where((s) =>
            term.isEmpty ||
            s.name.toLowerCase().contains(term) ||
            s.area.toLowerCase().contains(term) ||
            s.tags.any((t) => t.toLowerCase().contains(term)))
        .map(_listing)
        .toList();
  }

  @override
  Future<SpaceListing?> space(String id) async {
    await Future<void>.delayed(_latency);
    for (final sample in WellnessSpace.sample) {
      if (sample.id == id) return _listing(sample);
    }
    return null;
  }

  @override
  Future<bool> joinPassportWaitlist(
    String email, {
    String city = '',
    String source = '',
  }) async {
    await Future<void>.delayed(_latency);
    // Nothing is sent anywhere, so this must not claim a place was reserved
    // on a list that does not exist. The sheet says as much.
    return true;
  }

  // ----------------------------------------------------- the Passport flow
  //
  // Held in memory so the flow can be walked end to end without a server:
  // reserving moves a class from [_sessions] into [_held], the Hub reads
  // [_held], and cancelling puts it back. That is the same arithmetic the
  // server does, which is what makes the screens behave the same either way.

  final List<PassportReservation> _held = [];
  int _nextId = 1;

  List<StudioSession> _sessionsFor(String spaceId) {
    final tomorrow = _now().add(const Duration(days: 1));
    DateTime at(int hour) => DateTime(
          tomorrow.year, tomorrow.month, tomorrow.day, hour,
        );
    return [
      StudioSession(
        id: 101, title: 'Reformer Flow', category: 'reformer',
        startsAt: at(9), minutes: 60, instructor: 'Kemi A.',
        room: 'Studio A', spotsOpen: 3,
      ),
      StudioSession(
        id: 102, title: 'Mat Pilates', category: 'mat',
        startsAt: at(10), minutes: 60, instructor: 'Ada N.',
        room: 'Studio B', spotsOpen: 2,
      ),
      StudioSession(
        id: 103, title: 'Recovery Spa', category: 'yoga',
        startsAt: at(11), minutes: 60, instructor: 'Sade O.',
        room: 'Studio B', spotsOpen: 0, isFull: true,
      ),
    ];
  }

  @override
  Future<List<StudioSession>> sessions(String spaceId) async {
    await Future<void>.delayed(_latency);
    return _sessionsFor(spaceId);
  }

  @override
  Future<PassportReservation> reserve(int sessionId) async {
    await Future<void>.delayed(_latency);
    final already = _held.where((r) => r.id == sessionId);
    if (already.isNotEmpty) return already.first;

    final session = _sessionsFor('').firstWhere((s) => s.id == sessionId);
    final held = PassportReservation(
      // The session's own id, so reserving the same class twice is caught
      // the way the server catches it.
      id: sessionId,
      className: session.title,
      sessionType: session.category,
      startsAt: session.startsAt,
      code: 'STH${_nextId++}9A'.substring(0, 6),
      spaceName: 'Sage & She',
      spaceArea: 'Lekki Phase 1',
    );
    _held.add(held);
    return held;
  }

  @override
  Future<List<PassportReservation>> reservations() async {
    await Future<void>.delayed(_latency);
    return List.unmodifiable(_held);
  }

  @override
  Future<PassportReservation> cancelReservation(int reservationId) async {
    await Future<void>.delayed(_latency);
    final held = _held.firstWhere((r) => r.id == reservationId);
    _held.removeWhere((r) => r.id == reservationId);
    return PassportReservation(
      id: held.id,
      className: held.className,
      startsAt: held.startsAt,
      sessionType: held.sessionType,
      status: 'cancelled',
      code: held.code,
      spaceName: held.spaceName,
      spaceArea: held.spaceArea,
      canCancel: false,
    );
  }

  /// Roughly where these three places are. The map is a flat picture, so a
  /// pin is placed from a coordinate rather than projected -- without one
  /// every pin would stack in the middle of the image.
  static const _coordinates = <String, ({double lat, double lng})>{
    'sage-and-she': (lat: 6.4478, lng: 3.4723),   // Lekki Phase 1
    'still-house': (lat: 9.0845, lng: 7.4951),    // Maitama, Abuja
    'the-quiet-room': (lat: 6.4500, lng: 3.4350), // Ikoyi
  };

  SpaceListing _listing(WellnessSpace sample) => SpaceListing(
        id: sample.id,
        name: sample.name,
        area: sample.area,
        category: sample.category.name,
        tags: sample.tags,
        about: sample.about,
        photoUrl: sample.photo,
        instagram: sample.instagram,
        phone: sample.phone,
        latitude: _coordinates[sample.id]?.lat,
        longitude: _coordinates[sample.id]?.lng,
        distanceKm: sample.distanceKm,
      );
}
