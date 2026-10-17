import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/base_controller.dart';
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

  /// Where a studio's pin sits on the map image, as a fraction of its box.
  ///
  /// The design ships a flat picture rather than a map view, so a pin is
  /// placed, not projected. Placing it by spreading the listed studios
  /// across the image at least keeps their relative positions true; a real
  /// map widget would replace this whole method and the picture with it.
  ({double x, double y}) pinFor(SpaceListing space) {
    final located = spaces
        .where((s) => s.latitude != null && s.longitude != null)
        .toList();
    if (space.latitude == null || space.longitude == null || located.length < 2) {
      // Nothing to spread it against: park it in the middle rather than at
      // a corner, where it would look like a bug.
      return (x: 0.45, y: 0.45);
    }

    final lats = located.map((s) => s.latitude!).toList()..sort();
    final lngs = located.map((s) => s.longitude!).toList()..sort();
    final latSpan = lats.last - lats.first;
    final lngSpan = lngs.last - lngs.first;

    // Inset, so a pin at the extreme does not hang off the edge.
    final x = lngSpan == 0
        ? 0.45
        : 0.1 + 0.8 * ((space.longitude! - lngs.first) / lngSpan);
    // North is up: a larger latitude belongs nearer the top.
    final y = latSpan == 0
        ? 0.45
        : 0.1 + 0.8 * ((lats.last - space.latitude!) / latSpan);
    return (x: x, y: y);
  }

  @override
  void onInit() {
    super.onInit();
    search.addListener(() {
      query.value = search.text;
      _debounceSearch();
    });
    load();
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

  void clearPin() => selected.value = null;
}
