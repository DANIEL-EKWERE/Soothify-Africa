import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/article.dart';
import 'package:soothifyafrica/app/data/models/library_section.dart';
import 'package:soothifyafrica/app/modules/user/article/article_screen.dart';
import 'package:soothifyafrica/app/modules/user/article/controller/article_controller.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/article_test.dart
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  Future<void> mount(
    WidgetTester tester,
    Article article, {
    Brightness brightness = Brightness.light,
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    Get.put(ArticleController(article));
    await pumpScreen(tester, const ArticleScreen(), brightness: brightness);
    await precacheAll(
        tester, find.byType(ArticleScreen), [article.coverAsset]);
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    for (final article in Article.values) {
      testWidgets('article ${article.name}, $name', (tester) async {
        await mount(tester, article, brightness: brightness);

        await expectLater(find.byType(ArticleScreen),
            matchesGoldenFile('goldens/article_${article.name}_$name.png'));
      });
    }
  }

  testWidgets('the header, title and rating are the frame’s', (tester) async {
    await mount(tester, Article.core);
    expect(find.text('Articles'), findsOneWidget);
    expect(find.text('Why Your Core is More Than Just Six-Pack Abs'),
        findsOneWidget);
    expect(find.text('4.8/5'), findsOneWidget);
  });

  group('the call to action', () {
    test('is runs, not one string — the frame colours only two phrases', () {
      for (final article in Article.values) {
        final links = article.callToAction.where((r) => r.isLink);
        expect(links, hasLength(2),
            reason: 'both frames set exactly two phrases in blue');
        expect(
          links.map((r) => r.link).toSet(),
          {ArticleLink.library, ArticleLink.booking},
          reason: 'one goes to the library, one to booking',
        );
      }
    });

    test('reads as the whole sentence when the runs are joined', () {
      final joined =
          Article.core.callToAction.map((r) => r.text).join();
      expect(
        joined,
        'Ready to build real strength? Explore our complete Pilates & Core '
        'library or Book a 1-on-1 session with a certified core specialist '
        'to get a tailored routine.',
      );
    });
  });

  test('each article draws its own section’s photograph', () {
    // The frames' own cover is a stock poster mock-up; see [Article].
    expect(Article.core.section, LibrarySection.meditation);
    expect(Article.rest.section, LibrarySection.balance);
    expect(Article.core.coverAsset, isNot(Article.rest.coverAsset));
    for (final a in Article.values) {
      expect(a.coverAsset, isNotEmpty);
    }
  });
}
