import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:soothifyafrica/app/data/models/media_item.dart';
import 'package:soothifyafrica/app/data/services/video_pip_service.dart';

/// The video that keeps playing after its screen is gone.
///
/// The player used to be owned by the screen and disposed on the way out, so
/// leaving a video halfway stopped it dead.
void main() {
  // VideoPlayerController reaches for the platform the moment it is built.
  TestWidgetsFlutterBinding.ensureInitialized();

  const item = MediaItem(
    id: '7',
    title: 'Guided Breathing for calm',
    type: MediaType.video,
    durationSeconds: 300,
    remoteUrl: 'https://soothifyafrica.com.ng/api/v1/media/x.webm/',
  );

  late VideoPipService pip;

  setUp(() {
    Get.reset();
    pip = Get.put(VideoPipService());
  });
  tearDown(Get.reset);

  VideoPlayerController player() =>
      VideoPlayerController.networkUrl(Uri.parse(item.remoteUrl));

  test('nothing floats until a screen hands something over', () {
    expect(pip.showing, isFalse);
    expect(pip.release(item.id), isNull);
  });

  test('the screen it reopens on gets its own player back', () {
    final playing = player();
    pip.adopt(playing, item, from: 'Pilates');
    expect(pip.showing, isTrue);
    expect(pip.item.value?.id, '7');
    expect(pip.source, 'Pilates');

    // A different item opens its own; this one stays floating.
    expect(pip.release('other'), isNull);
    expect(pip.showing, isTrue);

    expect(pip.release('7'), same(playing));
    expect(pip.showing, isFalse,
        reason: 'handed back, so the window has nothing left to draw');
    expect(pip.source, isEmpty);
  });

  test('a second video replaces the first rather than playing over it', () {
    final first = player();
    final second = player();
    pip.adopt(first, item, from: 'Pilates');
    pip.adopt(second, item, from: 'Yoga');
    expect(pip.release('7'), same(second));
  });
}
