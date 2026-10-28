import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:soothifyafrica/app/core/utils/where_i_am.dart';
import 'package:soothifyafrica/app/data/models/space_listing.dart';
import 'package:soothifyafrica/app/data/repositories/spaces_repository.dart';
import 'package:soothifyafrica/app/modules/user/spaces/controller/spaces_controller.dart';

/// "Spaces Around Me" and where "me" is.
///
/// The server measures the distance from `?lat=&lng=` and has done all
/// along; the controller never passed them, so a screen called "around me"
/// knew nothing about where anybody was and every card omitted its
/// distance.
class _RecordingSpaces implements SpacesRepository {
  final asked = <({double? lat, double? lng})>[];

  @override
  Future<List<SpaceListing>> spaces({
    String category = 'all',
    String query = '',
    double? latitude,
    double? longitude,
  }) async {
    asked.add((lat: latitude, lng: longitude));
    return const [];
  }

  @override
  Future<SpaceListing?> space(String id) async => null;

  @override
  Future<bool> joinPassportWaitlist(
    String email, {
    String city = '',
    String source = '',
  }) async =>
      true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _RecordingSpaces repo;

  setUp(() {
    Get.testMode = true;
    repo = _RecordingSpaces();
    // No real device here, and nothing already allowed.
    WhereIAm.finder = () async => null;
  });

  tearDown(() {
    Get.reset();
    WhereIAm.finder = () async => null;
  });

  test('it opens without a location rather than prompting', () async {
    final controller = SpacesController(repo)..onInit();
    await controller.opening;

    expect(controller.locatedMe.value, isFalse);
    expect(repo.asked.single.lat, isNull);
  });

  test('asking for the location reloads with it', () async {
    WhereIAm.finder = () async => (latitude: 6.4474, longitude: 3.4736);
    final controller = SpacesController(repo)..onInit();
    await controller.opening;

    await controller.useMyLocation();

    expect(controller.locatedMe.value, isTrue);
    // The coordinates reach the server, which is what turns the
    // "2.4 km away" line on.
    expect(repo.asked.last.lat, closeTo(6.4474, 0.0001));
    expect(repo.asked.last.lng, closeTo(3.4736, 0.0001));
  });

  test('a refusal leaves the list working, without distances', () async {
    final controller = SpacesController(repo)..onInit();
    await controller.opening;

    await controller.useMyLocation();

    expect(controller.locatedMe.value, isFalse);
    expect(repo.asked.last.lat, isNull);
  });

  test('once known, the location is sent on every later request', () async {
    WhereIAm.finder = () async => (latitude: 6.5, longitude: 3.4);
    final controller = SpacesController(repo)..onInit();
    await controller.opening;
    await controller.useMyLocation();

    await controller.load();

    expect(repo.asked.last.lat, 6.5);
  });
}
