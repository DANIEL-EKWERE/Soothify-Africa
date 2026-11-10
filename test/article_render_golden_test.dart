import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/data/models/library_section.dart';
import 'package:soothifyafrica/app/data/models/media_item.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/modules/user/article/article_screen.dart';
import 'package:soothifyafrica/app/modules/user/article/controller/article_controller.dart';

import 'helpers.dart';

/// An article using every piece of formatting the dashboard offers.
///
/// A golden, because the thing being checked is layout: that a heading has
/// room above it, that a wrapped bullet lines up under its own first word
/// rather than under the bullet, and that bold inside a heading stays
/// heading-sized.
void main() {
  const formatted = '''
## Why your core matters

True core strength runs **deep**, wrapping around your spine like a natural
corset to protect your lower back and *improve posture*.

### Where to start

- Start slow, and keep the ribs down
- Breathe out on the effort, every time, even when the set is long enough that you stop wanting to
- Try [the daily focus session](media:1)

1. Five minutes a day
2. Then ten

Wind down with [our Deep Rest story](media:61), or
[take a breathing minute](breathe) first.
''';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    Get.put<ContentRepository>(MockContentRepository());
  });
  tearDown(Get.reset);

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('a formatted article, $name', (tester) async {
      await loadAppFonts();
      useDesignFrame(tester);

      const article = MediaItem(
        id: '60',
        title: 'Why Your Core is More Than Just Six-Pack Abs',
        type: MediaType.article,
        durationSeconds: 0,
        rating: 4.8,
        description: formatted,
      );
      Get.put(ArticleController(article, section: LibrarySection.meditation));

      await pumpScreen(
        tester,
        const ArticleScreen(),
        brightness: brightness,
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ArticleScreen),
        matchesGoldenFile('goldens/article_formatted_$name.png'),
      );
    });
  }

  testWidgets('the syntax never reaches the reader', (tester) async {
    await loadAppFonts();
    useDesignFrame(tester);

    const article = MediaItem(
      id: '60',
      title: 'Formatting',
      type: MediaType.article,
      durationSeconds: 0,
      description: formatted,
    );
    Get.put(ArticleController(article, section: LibrarySection.meditation));

    await pumpScreen(tester, const ArticleScreen());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Whatever else is wrong, the reader must never be shown the markup.
    for (final mark in ['##', '**', '](', 'media:1', '- Start']) {
      expect(find.textContaining(mark), findsNothing, reason: mark);
    }
    // And the words themselves did arrive.
    expect(find.textContaining('Why your core matters'), findsWidgets);
    expect(find.textContaining('Start slow'), findsWidgets);
  });
}
