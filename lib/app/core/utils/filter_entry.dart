import '../../data/models/media_filter.dart';
import '../app_export.dart';

/// Opens the filter flow and returns what the user applied, or null if they
/// backed out.
///
/// Shared by the libraries and Discovery so the one filter glyph in the app
/// always opens the same thing. [current] seeds the sheets, so reopening
/// filters shows what is already applied rather than a blank slate.
Future<FilterSelection?> openFilterSheets(FilterSelection current) async {
  final result = await Get.toNamed(
    AppRoutes.filterDuration,
    arguments: current,
  );
  return result is FilterSelection ? result : null;
}
