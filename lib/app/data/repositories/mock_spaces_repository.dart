import '../models/space_listing.dart';
import '../models/wellness_space.dart';
import 'spaces_repository.dart';

/// Studios without a server: the three the design draws, filtered the same
/// way the server filters them so the screen behaves identically.
class MockSpacesRepository implements SpacesRepository {
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
