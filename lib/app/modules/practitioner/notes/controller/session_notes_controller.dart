import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/expert_session.dart';

/// How the session went — Figma "Session notes | After session"
/// (`259:59854`), the three chips under "How did the session go".
enum SessionOutcome {
  goodProgress('Good progress'),
  steady('Steady'),
  needsFollowUp('Needs follow-up');

  const SessionOutcome(this.label);

  final String label;
}

/// Backs one session's notes.
class SessionNotesController extends GetxController {
  SessionNotesController()
      : session = Get.arguments is ExpertSession
            ? Get.arguments as ExpertSession
            : null;

  /// Null only if the route was opened without one, which the app never does.
  final ExpertSession? session;

  final Rxn<SessionOutcome> outcome = Rxn<SessionOutcome>();
  final summary = TextEditingController();
  final recommendation = TextEditingController();

  String get clientName => session?.clientName ?? 'this';

  String get title => '$clientName’s session notes';

  @override
  void onClose() {
    summary.dispose();
    recommendation.dispose();
    super.onClose();
  }

  void choose(SessionOutcome value) => outcome.value = value;

  /// Nothing stores an expert's notes yet, and a client can already see the
  /// recommendation tab — so saying it saved would be a claim about something
  /// another person will read.
  void save() =>
      AppFeedback.info('Saving session notes is not built yet.');
}
