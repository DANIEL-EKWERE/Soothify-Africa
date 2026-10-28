import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/base_controller.dart';
import '../../../../core/utils/feedback_utils.dart';
import '../../../../core/utils/where_i_am.dart';
import '../../../../data/models/space_listing.dart';
import '../../../../data/models/wellness_space.dart';
import '../../../../data/repositories/spaces_repository.dart';

/// List or map — the pill pair at (243, 218) on `282:25250`.
enum SpacesView { list, map }

/// Drives "Spaces Around Me" — Figma `282:25161` (list), `282:25250` (map)
/// and `282:25287` (a pin selected).
class SpacesController extends BaseController {
  SpacesController(this._spaces);

  final SpacesRepository _spaces;

  final Rx<SpacesView> view = SpacesView.list.obs;
  final Rx<SpaceCategory> category = SpaceCategory.all.obs;
  final TextEditingController search = TextEditingController();
  final RxString query = ''.obs;

  /// The pin tapped on the map, which raises the card at the foot of
  /// `282:25287`. Null means no pin is open.
  final Rxn<SpaceListing> selected = Rxn<SpaceListing>();

  /// What the server last answered with. The chips and the search field are
  /// sent to it rather than applied here: distance is measured server-side,
  /// and a studio that closed should stop appearing without a new build.
  final RxList<SpaceListing> spaces = <SpaceListing>[].obs;

  List<SpaceListing> get all => spaces;

  /// Where the phone is, once it has said. Null until then, and null for
  /// good if the person declines — the list works either way, it just
  /// cannot say how far away anything is.
  ({double latitude, double longitude})? _origin;

  /// Whether the distances on the cards are real.
  final RxBool locatedMe = false.obs;

  /// Asks for the location and reloads with it.
  ///
  /// Called from the "Use my location" button rather than on open: a
  /// permission prompt that appears the moment a screen does is the kind
  /// nobody reads.
  Future<void> useMyLocation() async {
    final here = await WhereIAm.get();
    if (here == null) {
      AppFeedback.info(
        'We could not get your location, so distances are hidden. The list '
        'still works.',
      );
      return;
    }
    _origin = here;
    locatedMe.value = true;
    await load();
  }

  @override
  void onInit() {
    super.onInit();
    search.addListener(() {
      query.value = search.text;
      _debounceSearch();
    });
    opening = _openWithWhatWeAlreadyHave();
  }

  /// The first load, so a test can await it rather than guess at a delay.
  late final Future<void> opening;

  /// Loads, then uses the location if permission was already given.
  ///
  /// The list comes first and never waits on the platform: asking about
  /// permission is a round trip, and a screen that holds its content back
  /// for it shows nothing in the meantime. Having been told once, though,
  /// there is no reason to make somebody press a button for what they
  /// already allowed -- so it reloads with distances straight after.
  Future<void> _openWithWhatWeAlreadyHave() async {
    await load();

    if (!await WhereIAm.alreadyAllowed()) return;
    final here = await WhereIAm.get();
    if (here == null) return;

    _origin = here;
    locatedMe.value = true;
    await load();
  }

  Timer? _typing;

  /// A request per keystroke would be a request per keystroke. A short
  /// pause after typing stops is what the server should see.
  void _debounceSearch() {
    _typing?.cancel();
    _typing = Timer(const Duration(milliseconds: 350), load);
  }

  Future<void> load() async {
    final found = await guard(
      () => _spaces.spaces(
        category: category.value.name,
        query: query.value,
        // What turns "2.4 km away" on. The server measures it; until this
        // was passed it had nothing to measure from.
        latitude: _origin?.latitude,
        longitude: _origin?.longitude,
      ),
      // The list renders its own empty state; a snackbar over a search box
      // is noise.
      showFeedback: false,
    );
    if (found == null) return;
    spaces.value = found;
    // The open pin may not have survived the new filter or search.
    final open = selected.value;
    if (open != null && !found.any((s) => s.id == open.id)) {
      selected.value = null;
    }
  }

  @override
  void onClose() {
    _typing?.cancel();
    search.dispose();
    super.onClose();
  }

  void showList() {
    view.value = SpacesView.list;
    // A card belongs to the map; leaving it open behind the list would raise
    // it again the next time the map is shown.
    selected.value = null;
  }

  void showMap() => view.value = SpacesView.map;

  void choose(SpaceCategory value) {
    if (category.value == value) return;
    category.value = value;
    // Filtering happens on the server, so a new chip means a new request --
    // without this the chips moved the highlight and nothing else.
    load();
  }

  void selectPin(SpaceListing space) => selected.value = space;

  /// Tapping the map away from a pin closes the card it raised.
  void closePin() => selected.value = null;

  /// Where the map opens: on the person if they have said, otherwise on
  /// the middle of what is listed, otherwise on Lagos.
  ///
  /// The fallback is a city rather than (0, 0), which is in the Atlantic
  /// and would read as a broken map.
  ({double latitude, double longitude}) get mapCentre {
    final here = _origin;
    if (here != null) return here;

    final placed = spaces
        .where((s) => s.latitude != null && s.longitude != null)
        .toList();
    if (placed.isEmpty) return (latitude: 6.4541, longitude: 3.3947);

    final lat = placed.map((s) => s.latitude!).reduce((a, b) => a + b);
    final lng = placed.map((s) => s.longitude!).reduce((a, b) => a + b);
    return (
      latitude: lat / placed.length,
      longitude: lng / placed.length,
    );
  }

  /// Only the spaces that can be put on a map. One without coordinates is
  /// still in the list; it simply has nowhere to be drawn.
  List<SpaceListing> get placed => spaces
      .where((s) => s.latitude != null && s.longitude != null)
      .toList();

  void clearPin() => selected.value = null;
}
