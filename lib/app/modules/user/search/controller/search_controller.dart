import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../core/utils/media_entry.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/repositories/content_repository.dart';

/// Searching the library.
///
/// The design draws the search field on four screens and no results page
/// behind it, so this follows the shelf grid (`135:20135`) — the same cards,
/// the same two columns — and is worth re-measuring if a frame appears.
///
/// The search itself runs on the server: it reads titles, practitioners and
/// tags across the whole library, which a filter over one loaded shelf
/// could not do.
class LibrarySearchController extends BaseController {
  LibrarySearchController(this._content, {String? initialQuery})
      : _initial = initialQuery ?? '' {
    field.text = _initial;
    query.value = _initial;
  }

  final ContentRepository _content;
  final String _initial;

  final field = TextEditingController();
  final RxString query = ''.obs;
  final RxList<MediaItem> results = <MediaItem>[].obs;

  /// True once a search has actually run, so an empty screen can tell the
  /// difference between "nothing matched" and "nothing asked yet".
  final RxBool searched = false.obs;

  Timer? _typing;

  @override
  void onInit() {
    super.onInit();
    field.addListener(() {
      query.value = field.text;
      _debounce();
    });
    if (_initial.trim().isNotEmpty) run();
  }

  @override
  void onClose() {
    _typing?.cancel();
    field.dispose();
    super.onClose();
  }

  /// A request per keystroke would be a request per keystroke.
  void _debounce() {
    _typing?.cancel();
    _typing = Timer(const Duration(milliseconds: 350), run);
  }

  Future<void> run() async {
    final term = query.value.trim();
    if (term.isEmpty) {
      results.clear();
      searched.value = false;
      return;
    }

    final found = await guard(
      () => _content.search(term),
      // The screen says "nothing matched" on its own; a snackbar over a
      // search box somebody is typing into is noise.
      showFeedback: false,
    );
    searched.value = true;
    if (found != null) results.assignAll(found);
  }

  void clear() {
    field.clear();
    results.clear();
    searched.value = false;
  }

  void open(MediaItem item) => openMedia(item, source: 'Search');
}
