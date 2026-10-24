import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/article.dart';
import 'package:soothifyafrica/app/data/models/library_section.dart';
import 'package:soothifyafrica/app/data/models/media_item.dart';
import 'package:soothifyafrica/app/modules/user/article/article_screen.dart';
import 'package:soothifyafrica/app/modules/user/article/controller/article_controller.dart';

import 'helpers.dart';

/// The article reader.
///
/// Articles used to be an enum of two, with their titles, bodies and
/// closing paragraphs written into the app — so adding a third meant
/// shipping a release, and nothing an author wrote in the dashboard ever
/// appeared. They are ordinary MediaItems now.
///
/// Regenerate with:
///   flutter test --update-goldens test/article_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  const core = MediaItem(
    id: '1',
    title: 'Why Your Core is More Than Just Six-Pack Abs',
    description: 'True core strength runs deep, wrapping around your spine '
        'like a natural corset to protect your lower back and improve '
        'posture.',
    type: MediaType.article,
    durationSeconds: 0,
    rating: 4.8,
    categoryId: 'focus',
    coverAsset: 'assets/images/explore/meditation.png',
  );

  const rest = MediaItem(
    id: '2',
    title: 'The Physiology of Deep Rest: Why Doing Nothing is Productive',
    description: 'Constant go-mode keeps your nervous system trapped in a '
        'chronic state of fight-or-flight.',
    type: MediaType.article,
    durationSeconds: 0,
    rating: 4.8,
    categoryId: 'calm',
    coverAsset: 'assets/images/explore/stretch_restore.png',
  );

  Future<void> mount(
    WidgetTester tester,
    MediaItem item, {
    LibrarySection? section,
    Brightness brightness = Brightness.light,
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put(ArticleController(item, section: section));
    await pumpScreen(tester, const ArticleScreen(), brightness: brightness);
    await precacheAll(tester, find.byType(ArticleScreen), [item.cover]);
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    for (final (key, item) in [('core', core), ('rest', rest)]) {
      testWidgets('article $key, $name', (tester) async {
        await mount(tester, item, brightness: brightness);

        await expectLater(find.byType(ArticleScreen),
            matchesGoldenFile('goldens/article_${key}_$name.png'));
      });
    }
  }

  testWidgets('the header, title and rating come from the piece itself',
      (tester) async {
    await mount(tester, core);

    expect(find.text('Articles'), findsOneWidget);
    expect(find.text('Why Your Core is More Than Just Six-Pack Abs'),
        findsOneWidget);
    expect(find.text('4.8/5'), findsOneWidget);
  });

  testWidgets('the body is whatever was written in the dashboard',
      (tester) async {
    const edited = MediaItem(
      id: '3',
      title: 'Something new',
      description: 'Written this morning by the team.',
      type: MediaType.article,
      durationSeconds: 0,
    );

    await mount(tester, edited);

    expect(find.text('Written this morning by the team.'), findsOneWidget);
  });

  group('the call to action', () {
    ArticleController build(MediaItem item, {LibrarySection? section}) =>
        ArticleController(item, section: section);

    test('is runs, not one string — the frame colours only two phrases', () {
      for (final item in [core, rest]) {
        final links = build(item).callToAction.where((r) => r.isLink);

        expect(links, hasLength(2),
            reason: 'both frames set exactly two phrases in blue');
        expect(
          links.map((r) => r.link).toSet(),
          {ArticleLink.library, ArticleLink.booking},
          reason: 'one goes to the library, one to booking',
        );
      }
    });

    test('names the section it belongs to', () {
      final joined =
          build(rest, section: LibrarySection.balance)
              .callToAction
              .map((r) => r.text)
              .join();

      // Generated rather than written per article: one an author has to
      // hand-write every time is one that gets skipped, and the article
      // then ends on nothing.
      expect(joined, contains('Stretch & Restore library'));
    });

    test('the section can be said, or worked out from the category', () {
      expect(build(core).section, LibrarySection.meditation);
      expect(build(rest).section, LibrarySection.balance);

      // The library knows which row it came off, which beats guessing.
      expect(
        build(core, section: LibrarySection.balance).section,
        LibrarySection.balance,
      );
    });
  });
}
