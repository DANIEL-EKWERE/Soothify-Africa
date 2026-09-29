/// The filter chips on "Spaces Around Me" — Figma `282:25161`.
///
/// `all` is drawn selected and filled brand blue; the rest are outlined.
enum SpaceCategory {
  all('All'),
  pilates('Pilates Studios'),
  // The frame's string carries a stray carriage return.
  yoga('Yoga Sanctuaries'),
  spa('Wellness Spas');

  const SpaceCategory(this.label);

  final String label;
}

/// A physical studio a client can visit — `282:25161` (list), `282:25287`
/// (map pin) and `282:25339` (profile).
class WellnessSpace {
  const WellnessSpace({
    required this.id,
    required this.name,
    required this.area,
    required this.distanceKm,
    required this.category,
    required this.tags,
    required this.photo,
    required this.about,
    required this.instagram,
    required this.phone,
    required this.pin,
  });

  final String id;
  final String name;

  /// "Lekki Phase 1" on the card; the profile prints "Maitama, Abuja * 27km".
  final String area;
  final double distanceKm;

  final SpaceCategory category;

  /// The grey pills under the name — "Reformer Pilates", "Mat Pilates".
  final List<String> tags;

  final String photo;
  final String about;

  /// Where "Connect on Instagram" and "Call Studio Desk" lead.
  final String instagram;
  final String phone;

  /// Where the pin sits on the map, as a fraction of the map's box. The
  /// design ships a flat image rather than a map view, so a pin is placed
  /// rather than projected — see [WellnessSpace.sample].
  final ({double x, double y}) pin;

  String get distanceLabel => '${distanceKm.toStringAsFixed(1)} km away';

  /// The design fills all three cards with the same studio. Kept as three so
  /// the list, the filters and the map have something to act on, with the
  /// frame's own studio first.
  static const List<WellnessSpace> sample = [
    WellnessSpace(
      id: 'sage-and-she',
      name: 'Sage & She',
      area: 'Lekki Phase 1',
      distanceKm: 2.4,
      category: SpaceCategory.pilates,
      tags: ['Reformer Pilates', 'Mat Pilates'],
      photo: 'assets/images/spaces/studio.png',
      about: 'A calm, light-filled studio for small-group pilates and '
          'mindful movement. Come as you are, at any level.',
      instagram: 'sageandshe',
      phone: '+2348000000000',
      pin: (x: 0.42, y: 0.17),
    ),
    WellnessSpace(
      id: 'still-house',
      name: 'Still House',
      area: 'Maitama, Abuja',
      distanceKm: 27,
      category: SpaceCategory.yoga,
      tags: ['Hatha', 'Restorative'],
      photo: 'assets/images/spaces/studio.png',
      about: 'A calm, light-filled studio for small-group pilates and '
          'mindful movement. Come as you are, at any level.',
      instagram: 'stillhouse',
      phone: '+2348000000001',
      pin: (x: 0.68, y: 0.44),
    ),
    WellnessSpace(
      id: 'the-quiet-room',
      name: 'The Quiet Room',
      area: 'Ikoyi',
      distanceKm: 5.1,
      category: SpaceCategory.spa,
      tags: ['Massage', 'Steam'],
      photo: 'assets/images/spaces/studio.png',
      about: 'A calm, light-filled studio for small-group pilates and '
          'mindful movement. Come as you are, at any level.',
      instagram: 'thequietroom',
      phone: '+2348000000002',
      pin: (x: 0.30, y: 0.66),
    ),
  ];
}
