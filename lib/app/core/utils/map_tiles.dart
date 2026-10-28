import 'package:flutter_map/flutter_map.dart';

/// Where the map's tiles come from.
///
/// A seam so a test can supply its own. Two reasons it has to exist: a
/// widget test has no network, so the real provider floods the run with
/// failed requests; and a golden of a live map would be at the mercy of
/// whatever OpenStreetMap served that minute, which is no test at all.
class MapTiles {
  const MapTiles._();

  /// Replaced in tests.
  static TileProvider Function() provider = NetworkTileProvider.new;

  static TileProvider get() => provider();
}
