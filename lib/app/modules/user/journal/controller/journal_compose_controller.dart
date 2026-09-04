import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';

/// Backs writing a journal entry.
///
/// The prompts are the app's own; the design shows one example
/// ("What do you feel about the meditation session?") and a way to swap it,
/// so the rest follow its shape until a real set is supplied.
class JournalComposeController extends BaseController {
  JournalComposeController({DateTime Function()? now})
      : startedAt = (now ?? DateTime.now)();

  final bodyController = TextEditingController();
  final messageController = TextEditingController();

  /// Fixed at construction so the header does not shift while writing — and
  /// injectable, because the header renders this date and time, which would
  /// otherwise make any golden of this screen stale within the minute.
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

  /// No store yet, so saving is not claimed. Wiring a repository replaces
  /// this body without touching the screen.
  void done() {
    if (bodyController.text.trim().isEmpty) {
      Get.back();
      return;
    }
    AppFeedback.info('Saving journal entries is not built yet.');
  }

  void send() => AppFeedback.info('Sending is not built yet.');
}
