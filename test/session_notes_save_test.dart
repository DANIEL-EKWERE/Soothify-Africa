import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:soothifyafrica/app/core/errors/app_exception.dart';
import 'package:soothifyafrica/app/data/models/expert_session.dart';
import 'package:soothifyafrica/app/data/models/media_item.dart';
import 'package:soothifyafrica/app/data/repositories/expert_repository.dart';
import 'package:soothifyafrica/app/modules/practitioner/notes/controller/session_notes_controller.dart';

/// Saving a session note, with and without a recommendation.
class _RecordingExperts implements ExpertRepository {
  final notes = <String>[];
  final recommended = <String>[];
  Object? noteFailure;

  @override
  Future<void> saveSessionNote(String sessionId, String body) async {
    final problem = noteFailure;
    if (problem != null) throw problem;
    notes.add('$sessionId:$body');
  }

  @override
  Future<void> recommend({
    required String sessionId,
    required String itemId,
    String note = '',
  }) async =>
      recommended.add('$sessionId:$itemId');

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used here');
}

ExpertSession aSession({String id = '8'}) => ExpertSession(
      id: id,
      clientName: 'Ada Obi',
      service: '1-on-1 Therapy',
      startsAt: DateTime(2026, 11, 2, 12),
      endsAt: DateTime(2026, 11, 2, 13),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  test('a note with a summary is saved', () async {
    final experts = _RecordingExperts();
    final controller =
        SessionNotesController.forSession(aSession(), experts);
    controller.summary.text = 'She arrived settled and we worked on breath.';

    await controller.save();

    expect(experts.notes, isNotEmpty, reason: 'the note never reached the API');
    expect(experts.notes.single, contains('8:'));
  });

  test('a picked item is sent as its own recommendation', () async {
    final experts = _RecordingExperts();
    final controller =
        SessionNotesController.forSession(aSession(), experts);
    controller.summary.text = 'Good session.';
    controller.picked.value = const MediaItem(
      id: '12',
      title: 'Evening wind-down',
      type: MediaType.video,
      durationSeconds: 1800,
    );

    await controller.save();

    expect(experts.notes, isNotEmpty);
    expect(experts.recommended.single, '8:12');
  });

  test('an empty summary saves nothing, and says why', () async {
    final experts = _RecordingExperts();
    final controller =
        SessionNotesController.forSession(aSession(), experts);

    await controller.save();

    expect(experts.notes, isEmpty);
    // On the screen, not only in a snackbar: "Save does nothing" is all a
    // practitioner can see when one fails to appear.
    expect(controller.whyNotSaved.value, contains('summary'));
  });

  test('a failure to save is left on the screen', () async {
    final experts = _RecordingExperts()
      ..noteFailure = const NetworkException('offline');
    final controller =
        SessionNotesController.forSession(aSession(), experts);
    controller.summary.text = 'Written, but the server was unreachable.';

    await controller.save();

    expect(controller.whyNotSaved.value, isNotEmpty);
  });

  test('a successful save clears the last refusal', () async {
    final experts = _RecordingExperts();
    final controller =
        SessionNotesController.forSession(aSession(), experts);

    await controller.save();                       // refused: no summary
    expect(controller.whyNotSaved.value, isNotEmpty);

    controller.summary.text = 'Now written.';
    await controller.save();

    expect(controller.whyNotSaved.value, isEmpty);
  });

  test('no session saves nothing', () async {
    final experts = _RecordingExperts();
    final controller = SessionNotesController.forSession(null, experts);
    controller.summary.text = 'Written with nothing to attach it to.';

    await controller.save();

    expect(experts.notes, isEmpty);
  });
}
