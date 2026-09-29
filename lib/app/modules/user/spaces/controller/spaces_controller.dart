import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../data/models/wellness_space.dart';

/// List or map — the pill pair at (243, 218) on `282:25250`.
enum SpacesView { list, map }

/// Drives "Spaces Around Me" — Figma `282:25161` (list), `282:25250` (map)
/// and `282:25287` (a pin selected).
class SpacesController extends GetxController {
  final Rx<SpacesView> view = SpacesView.list.obs;
  final Rx<SpaceCategory> category = SpaceCategory.all.obs;
  final TextEditingController search = TextEditingController();
  final RxString query = ''.obs;

  /// The pin tapped on the map, which raises the card at the foot of
  /// `282:25287`. Null means no pin is open.
  final Rxn<WellnessSpace> selected = Rxn<WellnessSpace>();

  List<WellnessSpace> get all => WellnessSpace.sample;

  /// The chips and the search field narrow the same list.
  List<WellnessSpace> get spaces {
    final q = query.value.trim().toLowerCase();
    return all.where((s) {
      final inCategory = category.value == SpaceCategory.all ||
          s.category == category.value;
      if (!inCategory) return false;
      if (q.isEmpty) return true;
      return s.name.toLowerCase().contains(q) ||
          s.area.toLowerCase().contains(q) ||
          s.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    search.addListener(() => query.value = search.text);
  }

  @override
  void onClose() {
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
    category.value = value;
    // The open pin may not survive the new filter.
    if (selected.value != null && !spaces.contains(selected.value)) {
      selected.value = null;
    }
  }

  void selectPin(WellnessSpace space) => selected.value = space;

  void clearPin() => selected.value = null;
}
