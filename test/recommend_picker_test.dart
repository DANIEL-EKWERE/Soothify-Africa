import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:soothifyafrica/app/data/models/expert_recommendation.dart';
import 'package:soothifyafrica/app/data/models/expert_session.dart';
import 'package:soothifyafrica/app/data/models/media_item.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_expert_repository.dart';
import 'package:soothifyafrica/app/modules/practitioner/recommend/controller/recommend_controller.dart';

/// Picking a piece of the library to send a client mid-call.
///
/// Reached from the call screen's "..." → "Recommend Contents" → a kind,
/// so the kind is settled before this screen exists.
void main() {
  // send() ends by leaving the screen and raising a snackbar, both of
  // which reach for the widgets binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockContentRepository content;
  late MockExpertRepository experts;

  final session = ExpertSession(
    id: '42',
    clientName: 'Ada Obi',
    service: '1-on-1 Therapy',
    startsAt: DateTime(2026, 10, 19, 17),
    endsAt: DateTime(2026, 10, 19, 18),
  );

  RecommendController build(ExpertContentKind kind) => RecommendController(
        content,
        experts,
        session: session,
        kind: kind,
      );

  setUp(() {
    // send() leaves the screen when it works. Without this, contextless
    // navigation throws rather than being recorded.
    Get.testMode = true;
    content = MockContentRepository();
    experts = MockExpertRepository();
  });

  tearDown(Get.reset);

  test('it lists only the kind that was chosen', () async {
    final audio = build(ExpertContentKind.audio);
    await audio.load();
    expect(audio.items, isNotEmpty);
    expect(audio.items.every((i) => i.type == MediaType.audio), isTrue);

    final video = build(ExpertContentKind.video);
    await video.load();
    expect(video.items, isNotEmpty);
    expect(video.items.every((i) => i.type == MediaType.video), isTrue);
  });

  test('a kind the library has none of comes back empty, not wrong', () async {
    final c = build(ExpertContentKind.article);
    await c.load();

    // The screen says "nothing of this kind in the library yet" rather
    // than offering audio under an article heading.
    expect(c.items, isEmpty);
  });

  test('the heading names the kind and the client', () async {
    expect(build(ExpertContentKind.video).title, 'Recommend a video');
    expect(build(ExpertContentKind.audio).title, 'Recommend audio');
    expect(build(ExpertContentKind.article).clientName, 'Ada Obi');
  });

  test('nothing can be sent until something is picked', () async {
    final c = build(ExpertContentKind.video);
    await c.load();

    expect(c.canSend, isFalse);

    c.choose(c.items.first);
    expect(c.canSend, isTrue);
  });

  test('tapping the chosen one again unpicks it', () async {
    final c = build(ExpertContentKind.video);
    await c.load();
    final first = c.items.first;

    c.choose(first);
    c.choose(first);

    expect(c.chosen.value, isNull);
  });

  test('sending names the session, never the client', () async {
    final c = build(ExpertContentKind.video);
    await c.load();
    c.choose(c.items.first);
    c.note.text = '  Try this before bed.  ';

    await c.send();

    final sent = experts.recommended.single;
    // The server reads the client off the booking, so no account id ever
    // travels from the app.
    expect(sent.session, '42');
    expect(sent.item, c.items.first.id);
    expect(sent.note, '  Try this before bed.  ');
  });

  test('a search that matches nothing leaves nothing chosen', () async {
    final c = build(ExpertContentKind.video);
    await c.load();
    c.choose(c.items.first);

    c.query.value = 'nothing matches this at all';
    await c.load();

    // A piece that fell out of the list cannot stay picked, or Send would
    // post something no longer on screen.
    expect(c.items, isEmpty);
    expect(c.chosen.value, isNull);
    expect(c.canSend, isFalse);
  });

  test('an empty search browses the kind rather than showing nothing', () async {
    final c = build(ExpertContentKind.audio);
    c.query.value = '';
    await c.load();

    // Unlike the client's own search, which answers an empty query with
    // nothing: this screen opens on a browse.
    expect(c.items, isNotEmpty);
  });
}
