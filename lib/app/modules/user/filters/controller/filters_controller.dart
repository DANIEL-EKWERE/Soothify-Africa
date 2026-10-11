import '../../../../core/app_export.dart';
import '../../../../data/models/media_filter.dart';

/// One controller per visit to a filter sheet.
///
/// The sheet edits a working copy of the library's filters and only hands it
/// back on Apply, so backing out changes nothing. Only one sheet is open at a
/// time — the glyph's menu chooses which — so the controller lives and dies
/// with that one route.
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

  /// Hands the working copy back to whoever opened the sheet.
  void apply() => Get.back(result: selection.value);
}
