import '../../../../core/app_export.dart';
import '../../../../data/models/media_filter.dart';

/// One controller for the whole filter flow, not one per sheet.
///
/// The three sheets edit a single working copy of the library's filters, so a
/// duration ticked on the first sheet survives a trip to Style and back. The
/// binding creates it on the first sheet only; the deeper two reuse it, and
/// GetX disposes it when that first route pops.
class FiltersController extends GetxController {
  FiltersController(FilterSelection initial) : selection = initial.copy().obs;

  /// The working copy. Nothing here reaches the library until [apply].
  final Rx<FilterSelection> selection;

  bool isSelected(FilterGroup group, String option) =>
      selection.value.isSelected(group, option);

  void toggle(FilterGroup group, String option) {
    selection.value.toggle(group, option);
    // The set mutated in place, so the Rx has to be told — an identical
    // reference never fires on its own.
    selection.refresh();
  }

  /// The frame draws Apply in its disabled variant, which is the state with
  /// nothing ticked.
  bool get canApply => selection.value.count > 0;

  int get count => selection.value.count;

  /// Hands the working copy back to whoever opened the flow. From a deeper
  /// sheet this returns to the sheet below, which passes it on in turn — see
  /// [openSheet] — so Apply always means apply, at any depth.
  void apply() => Get.back(result: selection.value);

  /// Opens Style or More Filters over the current sheet. If the user applies
  /// down there, this sheet closes too and carries the result up.
  Future<void> openSheet(String route) async {
    final result = await Get.toNamed(route);
    if (result is FilterSelection) Get.back(result: result);
  }
}
