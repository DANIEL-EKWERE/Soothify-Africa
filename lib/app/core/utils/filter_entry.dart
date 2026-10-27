import 'package:flutter/widgets.dart';

import '../../data/models/media_filter.dart';
import '../../data/repositories/content_repository.dart';
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
  // What the sheets offer, asked for the first time one is opened. Here
  // rather than at launch because nothing before this needs it, and the app
  // should not wait on it to start. The sheets fall back to the design's own
  // lists until it answers.
  await _loadTheCatalogueOnce();
  // The screen can be gone by the time that answers -- the menu hangs off
  // this widget's own box, and positioning against a dead one throws.
  if (!anchor.mounted) return null;

  final route = await showFilterMenu(anchor);
  if (route == null) return null;
  final result = await Get.toNamed(route, arguments: current);
  return result is FilterSelection ? result : null;
}

/// True once the catalogue has been fetched, so reopening the menu does not
/// ask again.
bool _asked = false;

Future<void> _loadTheCatalogueOnce() async {
  if (_asked || FilterCatalogue.instance.isLoaded) return;
  if (!Get.isRegistered<ContentRepository>()) return;
  _asked = true;
  try {
    await Get.find<ContentRepository>().loadFilterOptions();
  } catch (error) {
    // The sheets still open on the design's own lists. Asked again next
    // time, since the flag is only set to stop a burst of calls.
    _asked = false;
    Log.e('could not read the filter options', error: error);
  }
}
