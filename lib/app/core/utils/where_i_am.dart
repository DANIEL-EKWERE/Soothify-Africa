import 'package:geolocator/geolocator.dart';

import 'logger.dart';

/// Where the phone is, for the one screen that asks.
///
/// A thin wrapper so a test can replace it and nothing else has to know
/// which plugin does the asking. Everything about it is best effort:
/// "Spaces Around Me" is a perfectly good list without a location — it
/// simply cannot say how far away anything is — so a refusal, a disabled
/// radio or a slow fix all answer null rather than failing the screen.
class WhereIAm {
  const WhereIAm._();

  /// Replaced in tests.
  static Future<({double latitude, double longitude})?> Function() finder =
      _find;

  static Future<({double latitude, double longitude})?> get() => finder();

  /// Replaced in tests, which have no platform to ask.
  static Future<bool> Function() allowedCheck = _alreadyAllowed;

  /// Whether permission has already been given, without asking for it.
  ///
  /// Used to decide whether the screen may ask quietly on open or should
  /// wait to be asked: a permission prompt the moment a screen appears is
  /// the kind nobody reads.
  static Future<bool> alreadyAllowed() => allowedCheck();

  static Future<bool> _alreadyAllowed() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  static Future<({double latitude, double longitude})?> _find() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final at = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          // A list of studios in a city does not need metre accuracy, and
          // asking for it costs a slower fix and more battery.
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return (latitude: at.latitude, longitude: at.longitude);
    } catch (error) {
      // A timeout indoors is ordinary, not a fault worth showing anybody.
      Log.e('could not read the location', error: error);
      return null;
    }
  }
}
