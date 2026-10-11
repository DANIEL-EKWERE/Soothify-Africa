import 'package:flutter/widgets.dart';

import '../../data/models/media_filter.dart';
import '../../widgets/filter_menu.dart';
import '../app_export.dart';

/// Drops the filter menu under the glyph at [anchor], opens whichever sheet
/// the user picks, and returns what they applied — or null if they dismissed
/// the menu or backed out of the sheet.
///
/// Shared by the libraries, the See All grids, Videos and Discovery so the
/// one filter glyph in the app always opens the same thing. [current] seeds
/// the sheet, so reopening filters shows what is already applied rather than
/// a blank slate.
Future<FilterSelection?> openFilterSheets(
  BuildContext anchor,
  FilterSelection current,
) async {
  final route = await showFilterMenu(anchor);
  if (route == null) return null;
  final result = await Get.toNamed(route, arguments: current);
  return result is FilterSelection ? result : null;
}
