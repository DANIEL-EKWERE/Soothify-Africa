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

/// Tables in an article's body.
///
/// A phone is narrow. Three columns fit and should fill the width; six do
/// not, and should scroll sideways rather than give each column a word per
/// line.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    Get.put<ContentRepository>(MockContentRepository());
  });
  tearDown(Get.reset);

  const narrow = '''
A short routine for the evening.

| Pose | Hold | Breaths |
| --- | --- | --- |
| **Child's pose** | 1 min | 6 |
| Cat-cow | 30 s | 4 |
| Legs up the wall, with a cushion under the hips | 5 min | 20 |

Then try [the Deep Rest story](media:61).
''';

  const wide = '''
| Day | Pose | Hold | Breaths | Focus | Level |
| --- | --- | --- | --- | --- | --- |
| Mon | Child's pose | 1 min | 6 | Back | Easy |
| Tue | Cat-cow | 30 s | 4 | Spine | Easy |
''';

  Future<void> mount(WidgetTester tester, String body,
      {Brightness brightness = Brightness.light}) async {
    await loadAppFonts();
    useDesignFrame(tester);
    Get.put(ArticleController(
      MediaItem(
        id: '60',
        title: 'An evening routine',
        type: MediaType.article,
        durationSeconds: 0,
        rating: 4.8,
        description: body,
      ),
      section: LibrarySection.balance,
    ));
    await pumpScreen(tester, const ArticleScreen(), brightness: brightness);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    // The table sits below the cover and the title.
    await tester.drag(find.byType(ListView).first, const Offset(0, -380));
    await tester.pumpAndSettle();
  }

  Finder sideways() => find.byWidgetPredicate(
        (w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      );

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('a table that fits, $name', (tester) async {
      await mount(tester, narrow, brightness: brightness);
      await expectLater(find.byType(ArticleScreen),
          matchesGoldenFile('goldens/article_table_$name.png'));
    });
  }

  testWidgets('three columns fill the width and do not scroll', (tester) async {
    await mount(tester, narrow);
    expect(find.byType(Table), findsOneWidget);
    expect(sideways(), findsNothing);
  });

  testWidgets('six columns scroll sideways', (tester) async {
    await mount(tester, wide);
    expect(find.byType(Table), findsOneWidget);
    expect(sideways(), findsOneWidget,
        reason: 'six columns squeezed into a phone are unreadable');
  });

  testWidgets('a cell keeps its words, without the syntax', (tester) async {
    await mount(tester, narrow);
    expect(find.textContaining("Child's pose"), findsWidgets);
    expect(find.textContaining('| ---'), findsNothing);
    expect(find.textContaining('**'), findsNothing);
  });

  testWidgets('a long cell wraps rather than overflowing', (tester) async {
    await mount(tester, narrow);
    expect(tester.takeException(), isNull);
  });
}
