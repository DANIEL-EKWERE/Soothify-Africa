import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/media_item.dart';
import 'package:soothifyafrica/app/modules/user/media/controller/media_controller.dart';
import 'package:soothifyafrica/app/modules/user/media/media_screen.dart';

import 'helpers.dart';

const _art = [
  'assets/images/content/cover_a.png',
  'assets/images/media/instructor.png',
  'assets/images/media/badge.png',
];

/// Regenerate with:
///   flutter test --update-goldens test/media_golden_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  const item = MediaItem(
    id: '1',
    title: 'Serene Evenings',
    subtitle: 'Sleep',
    tag: 'Meditation',
    description: 'Discover the profound power of self-love with our Embrace '
        'Yourself meditation, a gentle practice for coming home to yourself.',
    type: MediaType.audio,
    durationSeconds: 900,
    rating: 4.8,
    coverAsset: 'assets/images/content/cover_a.png',
    practitionerName: 'Adeshola Wande',
  );

  MediaController boot() =>
      Get.put(MediaController(item, source: 'Top Picks for you'));

  testWidgets('it shows the player and the written material', (tester) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final c = boot();

    await pumpScreen(tester, const MediaScreen());
    await precacheAll(tester, find.byType(MediaScreen), _art);

    // The shelf the card came from titles the screen.
    expect(find.text('Top Picks for you'), findsOneWidget);
    expect(find.text('Serene Evenings'), findsOneWidget);
    expect(find.text('4.8/5'), findsOneWidget);
    expect(find.text('15 mins'), findsOneWidget);
    expect(find.textContaining('Discover the profound power'), findsOneWidget);
    expect(find.text('Adeshola Wande'), findsOneWidget);
    expect(find.text('Add Note'), findsOneWidget);
    // The frame opens at 2:34 of 15:00.
    expect(c.elapsedLabel, '2:34 / 15:00');

    await expectLater(find.byType(MediaScreen),
        matchesGoldenFile('goldens/media_detail.png'));
  });

  test('seeking is clamped to the item', () {
    final c = MediaController(item, source: 'x');
    c.seekBy(const Duration(minutes: -30));
    expect(c.position.value, Duration.zero);
    c.seekBy(const Duration(minutes: 30));
    expect(c.position.value, item.duration);
    expect(c.progress, 1.0);
  });

  test('an unrated item does not print a score', () {
    const unrated = MediaItem(
      id: '2',
      title: 'x',
      type: MediaType.audio,
      durationSeconds: 60,
    );
    expect(MediaController(unrated, source: 'x').ratingLabel, '—/5');
  });
}
