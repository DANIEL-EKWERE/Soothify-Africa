
import '../../../../core/base_controller.dart';
import '../../../../core/app_export.dart';
import '../../../../data/models/journal_entry.dart';

/// Backs the Journal.
///
/// Only the empty state is designed so far (`135:2091`), so entries stay empty
/// until the populated frame (`135:2105`) is read and a store exists. The list
/// is here rather than hardcoding emptiness, so wiring a repository later does
/// not mean rewriting the screen.
class JournalController extends BaseController {
  final RxList<JournalEntry> entries = <JournalEntry>[].obs;

  bool get isEmpty => entries.isEmpty;

  void compose() => Get.toNamed(AppRoutes.journalCompose);
}
