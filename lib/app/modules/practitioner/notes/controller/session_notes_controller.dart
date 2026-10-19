import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/expert_recommendation.dart';
import '../../../../data/models/expert_session.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/repositories/expert_repository.dart';
import '../../recommend/binding/recommend_binding.dart';

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
///
/// The note is clinical: the server never serves it to the client, and the
/// screen that writes it is the only place it is read back.
class SessionNotesController extends BaseController {
  SessionNotesController(this._experts)
      : session = Get.arguments is ExpertSession
            ? Get.arguments as ExpertSession
            : null;

  /// For tests and for callers that hold the session already, rather than
  /// passing it through the route.
  SessionNotesController.forSession(this.session, this._experts);

  final ExpertRepository _experts;

  /// Null only if the route was opened without one, which the app never does.
  final ExpertSession? session;

  final Rxn<SessionOutcome> outcome = Rxn<SessionOutcome>();

  /// The piece of the library going to the client with this note — the
  /// frame draws it under "Recommendation", between the box and Save.
  ///
  /// Nothing until one is picked. It used to open on the frame's own
  /// sample video, which meant every note offered the same recommendation
  /// whether or not the practitioner chose anything.
  final Rxn<MediaItem> picked = Rxn<MediaItem>();

  /// The card the frame draws, from whatever is picked.
  ExpertContent? get content {
    final item = picked.value;
    if (item == null) return null;
    final minutes = (item.durationSeconds / 60).round();
    return ExpertContent(
      id: item.id,
      kind: switch (item.type) {
        MediaType.video => ExpertContentKind.video,
        MediaType.article => ExpertContentKind.article,
        MediaType.audio => ExpertContentKind.audio,
      },
      title: item.title,
      meta: [
        if (minutes > 0) '$minutes min',
        if (item.tag.isNotEmpty) item.tag,
      ].join(' '),
      coverUrl: item.coverUrl,
      coverAsset: item.coverAsset,
    );
  }
  final summary = TextEditingController();
  final recommendation = TextEditingController();

  String get clientName => session?.clientName ?? 'this';

  String get title => '$clientName’s session notes';

  @override
  void onInit() {
    super.onInit();
    _readWhatWasWritten();
  }

  /// A note already written comes back into the box, so the second visit
  /// adds to it rather than starting again.
  Future<void> _readWhatWasWritten() async {
    final id = session?.id;
    if (id == null || id.isEmpty) return;

    final written = await guard(
      () => _experts.sessionNote(id),
      showFeedback: false,
    );
    if (written == null || written.isEmpty) return;

    final parts = written.split(_outcomeMarker);
    summary.text = parts.first.trimRight();
    if (parts.length > 1) {
      final rest = parts[1].split(_recommendationMarker);
      outcome.value = _outcomeFromLabel(rest.first.trim());
      if (rest.length > 1) recommendation.text = rest[1].trim();
    }
  }

  @override
  void onClose() {
    summary.dispose();
    recommendation.dispose();
    super.onClose();
  }

  void choose(SessionOutcome value) => outcome.value = value;

  /// Choose what to send the client, or change it.
  ///
  /// The same picker the call screen opens, in its pick-only mode: this
  /// screen is written after the session, so nothing is sent until Save.
  Future<void> pick(ExpertContentKind kind) async {
    final chosen = await Get.toNamed(
      AppRoutes.expertRecommend,
      arguments: RecommendArguments(
        session: session!,
        kind: kind,
        pickOnly: true,
      ),
    );
    if (chosen is MediaItem) picked.value = chosen;
  }

  void clearPick() => picked.value = null;

  /// Saves the note against the session.
  ///
  /// The three parts the frame collects are one body server-side: the note
  /// is a document a clinician writes, not a form with columns, and marking
  /// the sections in the text keeps them readable when they come back.
  Future<void> save() async {
    final id = session?.id;
    if (id == null || id.isEmpty) {
      AppFeedback.error(const ValidationException(
        'Open a session from your schedule to write its notes.',
      ));
      return;
    }
    if (isLoading.value) return;
    if (summary.text.trim().isEmpty) {
      AppFeedback.error(const ValidationException(
        'Write the session summary before saving.',
      ));
      return;
    }

    final item = picked.value;
    final saved = await guard(() async {
      await _experts.saveSessionNote(id, _body());
      // The note is the practitioner's own record and never leaves; the
      // recommendation is the one thing from this screen the client sees,
      // so it is sent as its own row rather than buried in the note.
      if (item != null) {
        await _experts.recommend(
          sessionId: id,
          itemId: item.id,
          note: recommendation.text,
        );
      }
      return true;
    });
    if (saved != true) return;

    AppFeedback.info(
      item == null
          ? 'Saved. Only you can read this.'
          : 'Saved. Only you can read the note; '
              '${session?.clientName ?? 'your client'} gets the recommendation.',
    );
    Get.back();
  }

  static const _outcomeMarker = '\n\nHow it went: ';
  static const _recommendationMarker = '\n\nRecommendation: ';

  /// What is kept against the session, for the practitioner alone.
  ///
  /// The recommendation text is still written here as well as sent. It is
  /// part of what happened in the session, and a note that omits what was
  /// suggested is an incomplete record -- while the client's copy can be
  /// read back by neither of them from here.
  String _body() {
    final parts = StringBuffer(summary.text.trim());
    final how = outcome.value;
    if (how != null) parts.write('$_outcomeMarker${how.label}');
    final suggested = recommendation.text.trim();
    if (suggested.isNotEmpty) {
      parts.write('$_recommendationMarker$suggested');
    }
    return parts.toString();
  }

  SessionOutcome? _outcomeFromLabel(String label) {
    for (final value in SessionOutcome.values) {
      if (value.label == label) return value;
    }
    return null;
  }
}
