import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:soothifyafrica/app/data/models/media_item.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/modules/user/media/binding/media_binding.dart';
import 'package:soothifyafrica/app/modules/user/media/controller/media_controller.dart';

/// Opening a media item, and the blank screen that came of not doing it the
/// one way.
///
/// Profile -> Daily Stretch & Restore -> "Start" lists two recommendations.
/// Tapping one pushed the media route with the item on its own, where the
/// binding casts the arguments to a Map -- so it threw, the controller was
/// never built, and the screen opened grey and empty with nothing said.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const item = MediaItem(
    id: '1',
    title: 'Evening wind-down',
    type: MediaType.video,
    durationSeconds: 600,
  );

  setUp(() {
    Get.testMode = true;
    Get.put<ContentRepository>(MockContentRepository());
  });

  tearDown(Get.reset);

  // What GetX hands the binding on a push. Exercised through `bindMedia`
  // because `Get.arguments` has no setter.
  void bind(Object? arguments) => bindMedia(arguments);

  test('the shared opener builds the controller', () {
    bind({'item': item, 'source': 'Daily Stretch & Restore'});

    final controller = Get.find<MediaController>();
    expect(controller.item.title, 'Evening wind-down');
    expect(controller.source, 'Daily Stretch & Restore');
  });

  test('a bare item is accepted rather than throwing', () {
    // The Daily screen's old call. It should not take the screen down.
    bind(item);

    expect(Get.find<MediaController>().item.title, 'Evening wind-down');
    expect(Get.find<MediaController>().source, '');
  });

  test('no arguments leaves no controller, and does not throw', () {
    // The screen draws "That content could not be opened" off this.
    bind(null);

    expect(Get.isRegistered<MediaController>(), isFalse);
  });
}
