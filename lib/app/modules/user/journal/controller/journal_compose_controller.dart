import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/journal_entry.dart';
import '../../../../data/repositories/journal_repository.dart';

/// Backs writing a journal entry — Figma `259:29454`.
///
/// The prompts are the app's own; the design shows one example
/// ("What do you feel about the meditation session?") and a way to swap it,
/// so the rest follow its shape until a real set is supplied.
///
/// The frames draw no reader for a saved entry, and the list's chevron has to
/// open something, so this doubles as one: opened with a [JournalEntry] it
/// loads that note and saving replaces it.
class JournalComposeController extends BaseController {
  JournalComposeController(
    this._repository, {
    JournalEntry? entry,
    DateTime Function()? now,
  })  : existing = entry,
        startedAt = entry?.createdAt ?? (now ?? DateTime.now)() {
    if (entry != null) bodyController.text = entry.body;
  }

  final JournalRepository _repository;

  /// The note being edited, or null when this is a new one.
  final JournalEntry? existing;

  final bodyController = TextEditingController();
  final messageController = TextEditingController();

  /// Fixed at construction so the header does not shift while writing — and
  /// injectable, because the header renders this date and time, which would
  /// otherwise make any golden of this screen stale within the minute. An
  /// entry being re-opened shows the day it was written.
  final DateTime startedAt;

  static const List<String> _prompts = [
    'What do you feel about the meditation session?',
    'What is one thing that went well today?',
    'What is weighing on you right now?',
    'What would you like to let go of?',
  ];

  final RxInt _promptIndex = 0.obs;

  /// A plain getter, not a fresh `.obs` per call — reading `_promptIndex`
  /// here is what registers the dependency inside an Obx.
  String get prompt => _prompts[_promptIndex.value];

  @override
  void onClose() {
    bodyController.dispose();
    messageController.dispose();
    super.onClose();
  }

  void changePrompt() =>
      _promptIndex.value = (_promptIndex.value + 1) % _prompts.length;

  /// Saves and leaves.
  ///
  /// An emptied note is a deletion, not a blank entry: clearing the text of
  /// an existing one and pressing Done removes it rather than leaving a card
  /// with nothing on it.
  Future<void> done() async {
    final body = bodyController.text.trim();
    if (body.isEmpty) {
      if (existing != null) await _repository.delete(existing!.id);
      Get.back();
      return;
    }
    // guard returns null when the write failed and has already said so;
    // leaving then would look like it saved.
    final saved =
        await guard(() => _repository.save(body: body, id: existing?.id));
    if (saved == null) return;
    Get.back();
  }

  void send() => AppFeedback.info('Sending is not built yet.');
}
