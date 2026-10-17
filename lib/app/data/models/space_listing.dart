/// A studio as the server lists it — Spaces Around Me.
///
/// Distinct from the bundled [WellnessSpace] sample: this one carries a real
/// distance, measured from where the phone says it is, and a null distance
/// when it did not say. A card then shows nothing rather than claiming the
/// studio is next door.
class SpaceListing {
  const SpaceListing({
    required this.id,
    required this.name,
    required this.area,
    this.city = '',
    this.category = 'pilates',
    this.tags = const [],
    this.about = '',
    this.photoUrl = '',
    this.instagram = '',
    this.phone = '',
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  final String id;
  final String name;
  final String area;
  final String city;

  /// 'pilates', 'yoga' or 'spa' — the chips' own values.
  final String category;
  final List<String> tags;
  final String about;
  final String photoUrl;
  final String instagram;
  final String phone;
  final double? latitude;
  final double? longitude;

  /// Null when the phone shared no location.
  final double? distanceKm;

  String get distanceLabel =>
      distanceKm == null ? '' : '${distanceKm!.toStringAsFixed(1)} km away';

  factory SpaceListing.fromJson(Map<String, dynamic> json) => SpaceListing(
        id: '${json['id']}',
        name: json['name'] as String? ?? '',
        area: json['area'] as String? ?? '',
        city: json['city'] as String? ?? '',
        category: json['category'] as String? ?? 'pilates',
        tags: (json['tags'] as List?)?.map((t) => '$t').toList() ?? const [],
        about: json['about'] as String? ?? '',
        photoUrl: json['photo_url'] as String? ?? '',
        instagram: json['instagram'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
      );
}
