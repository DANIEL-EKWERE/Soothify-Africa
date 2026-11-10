import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/checkout_launcher.dart';
import 'package:soothifyafrica/app/core/utils/size_utils.dart';
import 'package:soothifyafrica/app/data/models/article_body.dart';
import 'package:soothifyafrica/app/data/models/library_section.dart';
import 'package:soothifyafrica/app/data/models/media_item.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/modules/user/article/article_screen.dart';
import 'package:soothifyafrica/app/modules/user/article/controller/article_controller.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';
import 'package:soothifyafrica/app/widgets/custom_image_view.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';

import 'helpers.dart';

/// Links an author embeds in an article's body.
///
/// Written on the media dashboard in a plain text field:
///
///     Wind down with [our Deep Rest story](media:42) tonight.
///
/// The parser is where the bugs would live, so most of this is about what
/// it does with text that is not quite a link.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(Get.reset);

  group('parseArticleBody', () {
    test('a body with no links is one plain run', () {
      final spans = parseArticleBody('Just some prose.');
      expect(spans, hasLength(1));
      expect(spans.single.isLink, isFalse);
      expect(spans.single.text, 'Just some prose.');
    });

    test('an empty body is nothing at all', () {
      expect(parseArticleBody(''), isEmpty);
    });

    test('it splits prose, link, prose', () {
      final spans = parseArticleBody(
        'Wind down with [our Deep Rest story](media:42) tonight.',
      );
      expect(spans.map((s) => s.text), [
        'Wind down with ',
        'our Deep Rest story',
        ' tonight.',
      ]);
      expect(spans[0].isLink, isFalse);
      expect(spans[1].tap, const ArticleTap(ArticleTarget.media, id: '42'));
      expect(spans[2].isLink, isFalse);
    });

    test('a link at the very start and very end', () {
      final spans = parseArticleBody('[Start](media:1) and [end](media:2)');
      expect(spans.first.isLink, isTrue);
      expect(spans.last.isLink, isTrue);
      expect(spans.map((s) => s.text), ['Start', ' and ', 'end']);
    });

    test('several links in one paragraph', () {
      final spans = parseArticleBody(
        'Try [this](media:1), then [that](media:2), then [the other](media:3).',
      );
      expect(spans.where((s) => s.isLink), hasLength(3));
    });

    test('the same phrase twice is two separate links', () {
      // Splitting on the link text would collapse these into one.
      final spans = parseArticleBody(
        '[listen](media:1) or [listen](media:2)',
      );
      final links = spans.where((s) => s.isLink).toList();
      expect(links, hasLength(2));
      expect(links[0].tap!.id, '1');
      expect(links[1].tap!.id, '2');
    });

    group('text that is not quite a link', () {
      test('a stray bracket is left as typed', () {
        const body = 'He said [sic] and carried on.';
        final spans = parseArticleBody(body);
        expect(spans.single.text, body);
        expect(spans.single.isLink, isFalse);
      });

      test('an unknown destination stays visible as text', () {
        // A blue phrase that does nothing is worse than visible syntax:
        // only one of the two tells anybody something is wrong.
        const body = 'Read [the thing](mailto:a@b.com) now.';
        final spans = parseArticleBody(body);
        expect(spans.single.text, body);
      });

      test('an empty media id is not a link', () {
        const body = 'Read [the thing](media:) now.';
        expect(parseArticleBody(body).single.text, body);
      });

      test('an unclosed link is left alone', () {
        const body = 'Read [the thing](media:1 and more';
        expect(parseArticleBody(body).single.text, body);
      });

      test('a bracket cannot swallow the rest of the paragraph', () {
        const body =
            'An [open bracket here and a ](media:1) much later on.';
        final spans = parseArticleBody(body);
        // The link text may not contain a bracket of its own, so the first
        // '[' does not pair with the far-away ']'.
        expect(spans.any((s) => s.text.contains('much later on')), isTrue);
      });
    });

    group('destinations', () {
      test('media, article and content are the same lookup', () {
        for (final scheme in ['media', 'article', 'content']) {
          expect(
            ArticleTap.parse('$scheme:7'),
            const ArticleTap(ArticleTarget.media, id: '7'),
            reason: scheme,
          );
        }
      });

      test('the standalone destinations', () {
        expect(ArticleTap.parse('library')!.target, ArticleTarget.library);
        expect(ArticleTap.parse('booking')!.target, ArticleTarget.booking);
        expect(ArticleTap.parse('book')!.target, ArticleTarget.booking);
        expect(ArticleTap.parse('breathe')!.target, ArticleTarget.breathe);
      });

      test('a web address leaves the app', () {
        final tap = ArticleTap.parse('https://soothifyafrica.com.ng/help');
        expect(tap!.target, ArticleTarget.external);
        expect(tap.id, 'https://soothifyafrica.com.ng/help');
      });

      test('case and surrounding space do not matter', () {
        expect(
          ArticleTap.parse('  MEDIA:42  '),
          const ArticleTap(ArticleTarget.media, id: '42'),
        );
      });

      test('nonsense is refused rather than guessed at', () {
        for (final destination in ['', '   ', 'wat', 'wat:1', 'ftp://x']) {
          expect(ArticleTap.parse(destination), isNull, reason: destination);
        }
      });
    });
  });

  group('following a link', () {
    const article = MediaItem(
      id: '60',
      title: 'Why Your Core is More Than Just Six-Pack Abs',
      type: MediaType.article,
      durationSeconds: 0,
      description: 'Start with [the daily focus session](media:1).',
    );

    late ArticleController controller;

    setUp(() {
      Get.put<ContentRepository>(MockContentRepository());
      controller = ArticleController(
        article,
        section: LibrarySection.meditation,
        content: Get.find<ContentRepository>(),
      );
    });

    List<GetPage<dynamic>> routes() => [
          GetPage(name: AppRoutes.media, page: () => const Text('player')),
          GetPage(name: AppRoutes.article, page: () => const Text('reader')),
          GetPage(name: AppRoutes.library, page: () => const Text('library')),
          GetPage(name: AppRoutes.breathe, page: () => const Text('breathe')),
        ];

    testWidgets('a media link opens the player', (tester) async {
      Get.testMode = true;
      await pumpScreen(tester, const SizedBox.shrink(), pages: routes());

      controller.followTap(const ArticleTap(ArticleTarget.media, id: '1'));
      await settleLoads(tester);

      expect(find.text('player'), findsOneWidget);
    });

    testWidgets('a link to an article opens the reader, not the player',
        (tester) async {
      Get.testMode = true;
      await pumpScreen(tester, const SizedBox.shrink(), pages: routes());

      controller.followTap(const ArticleTap(ArticleTarget.media, id: '61'));
      await settleLoads(tester);

      expect(find.text('reader'), findsOneWidget);
      expect(find.text('player'), findsNothing);
    });

    testWidgets('breathe and library go where they say', (tester) async {
      Get.testMode = true;
      await pumpScreen(tester, const SizedBox.shrink(), pages: routes());

      controller.followTap(const ArticleTap(ArticleTarget.breathe));
      await settleLoads(tester);
      expect(find.text('breathe'), findsOneWidget);
    });

    testWidgets('a link to a piece that has gone says so', (tester) async {
      Get.testMode = true;
      await pumpScreen(tester, const SizedBox.shrink(), pages: routes());

      controller.followTap(const ArticleTap(ArticleTarget.media, id: '9999'));
      await settleLoads(tester);

      // No navigation, and nothing thrown.
      expect(find.text('player'), findsNothing);
      expect(controller.isFollowing.value, isFalse);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('an article linking to itself does nothing', (tester) async {
      // Easy to do by accident when copying ids, and it would push a second
      // copy of the screen being read on top of itself.
      Get.testMode = true;
      await pumpScreen(tester, const SizedBox.shrink(), pages: routes());

      controller.followTap(const ArticleTap(ArticleTarget.media, id: '60'));
      await settleLoads(tester);

      expect(find.text('reader'), findsNothing);
    });

    test('an external link is handed to the phone', () async {
      final asked = <String>[];
      ExternalLink.opener = (url) async {
        asked.add(url);
        return true;
      };
      addTearDown(() => ExternalLink.opener = ExternalLink.open);

      await controller.followTap(
        const ArticleTap(ArticleTarget.external, id: 'https://example.com'),
      );
      expect(asked, ['https://example.com']);
    });

    test('with no repository it does not throw', () async {
      // The reader must open even where nothing was registered.
      final bare = ArticleController(article, section: LibrarySection.balance);
      await bare.followTap(const ArticleTap(ArticleTarget.media, id: '1'));
      expect(bare.isFollowing.value, isFalse);
    });
  });

  group('end to end', () {
    test('a link survives the whole way from the server', () async {
      // Tested as a chain, not link by link. Every piece of this can be
      // right on its own while the chain is broken -- the server's JSON
      // key, the model's field, the parser, the span. What matters is that
      // a body an author typed on the dashboard arrives as something a
      // reader can tap.
      final fromServer = MediaItem.fromJson({
        'id': '60',
        'title': 'Why Your Core is More Than Just Six-Pack Abs',
        'media_type': 'article',
        'duration_seconds': 0,
        'description': 'Wind down with [our Deep Rest story](media:42) '
            'tonight, or [take a breathing minute](breathe) first.',
      });

      expect(fromServer.type, MediaType.article);

      final controller = ArticleController(
        fromServer,
        section: LibrarySection.balance,
      );
      expect(controller.bodyHasLinks, isTrue);

      final links = controller.bodySpans.where((s) => s.isLink).toList();
      expect(links, hasLength(2));
      expect(links[0].text, 'our Deep Rest story');
      expect(links[0].tap, const ArticleTap(ArticleTarget.media, id: '42'));
      expect(links[1].tap, const ArticleTap(ArticleTarget.breathe));

      // And none of the syntax is left in what the reader sees.
      final shown = controller.bodySpans.map((s) => s.text).join();
      expect(shown, isNot(contains('](')));
      expect(shown, isNot(contains('media:42')));
      expect(shown, startsWith('Wind down with our Deep Rest story'));
    });
  });

  group('a picture in the body', () {
    Future<Size?> sizeOfBodyImage(WidgetTester tester, String body) async {
      useDesignFrame(tester);
      Get.put<ContentRepository>(MockContentRepository());
      Get.put(ArticleController(
        MediaItem(
          id: '60',
          title: 'A piece',
          type: MediaType.article,
          durationSeconds: 0,
          description: body,
        ),
        section: LibrarySection.balance,
      ));

      await pumpScreen(tester, const ArticleScreen());
      await tester.pump(const Duration(milliseconds: 600));

      for (final element in find.byType(CustomImageView).evaluate()) {
        final widget = element.widget as CustomImageView;
        if ((widget.imagePath ?? '').startsWith('http')) {
          return (element.renderObject as RenderBox).size;
        }
      }
      return null;
    }

    testWidgets('is drawn at a size somebody can see', (tester) async {
      // It used to draw at 342 by 0: CustomImageView hands its own height
      // to the placeholder, and a placeholder of height null in a Column
      // has unbounded height to fill and fills none of it. The picture was
      // in the body, parsed correctly, and invisible.
      final size = await sizeOfBodyImage(
        tester,
        'Before.\n\n![A mat](https://example.test/x.png)\n\nAfter.',
      );

      expect(size, isNotNull, reason: 'no body image was rendered at all');
      expect(size!.height, greaterThan(100),
          reason: 'the picture is there but has no height');
      expect(size.width, greaterThan(300));
    });

    testWidgets('the space is held while it loads', (tester) async {
      // Same assertion, made immediately: nothing has had a chance to
      // load, so this is the placeholder's size. A zero here is the text
      // below jumping when the picture arrives.
      useDesignFrame(tester);
      Get.put<ContentRepository>(MockContentRepository());
      Get.put(ArticleController(
        const MediaItem(
          id: '60',
          title: 'A piece',
          type: MediaType.article,
          durationSeconds: 0,
          description: '![](https://example.test/x.png)',
        ),
        section: LibrarySection.balance,
      ));
      await pumpScreen(tester, const ArticleScreen());

      final found = find.byType(CustomImageView).evaluate().where(
            (e) => ((e.widget as CustomImageView).imagePath ?? '')
                .startsWith('http'),
          );
      expect(found, isNotEmpty);
      expect((found.first.renderObject as RenderBox).size.height,
          greaterThan(100));
    });

    testWidgets('the alt text is shown as a caption', (tester) async {
      useDesignFrame(tester);
      Get.put<ContentRepository>(MockContentRepository());
      Get.put(ArticleController(
        const MediaItem(
          id: '60',
          title: 'A piece',
          type: MediaType.article,
          durationSeconds: 0,
          description: '![A reformer mat](https://example.test/x.png)',
        ),
        section: LibrarySection.balance,
      ));
      await pumpScreen(tester, const ArticleScreen());
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('A reformer mat'), findsOneWidget);
    });
  });

  group('the reader', () {
    testWidgets('an embedded link is tappable, and the prose is not',
        (tester) async {
      Get.testMode = true;
      Get.put<ContentRepository>(MockContentRepository());
      const article = MediaItem(
        id: '60',
        title: 'Deep rest',
        type: MediaType.article,
        durationSeconds: 0,
        description: 'Wind down with [the daily focus session](media:1) '
            'tonight.',
      );
      Get.put(ArticleController(article, section: LibrarySection.balance));

      await tester.pumpWidget(
        Sizer(
          builder: (_, _, _) => GetMaterialApp(
            theme: theme,
            home: const ArticleScreen(),
            getPages: [
              GetPage(name: AppRoutes.media, page: () => const Text('player')),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      // The link text is rendered, and the syntax is not.
      expect(find.textContaining('the daily focus session'), findsWidgets);
      expect(find.textContaining('](media:1)'), findsNothing);
      expect(find.textContaining('[the daily'), findsNothing);
    });

    testWidgets('a body with no links still renders', (tester) async {
      Get.testMode = true;
      Get.put<ContentRepository>(MockContentRepository());
      const article = MediaItem(
        id: '61',
        title: 'Deep rest',
        type: MediaType.article,
        durationSeconds: 0,
        description: 'Constant go-mode keeps your nervous system trapped.',
      );
      Get.put(ArticleController(article, section: LibrarySection.balance));

      await tester.pumpWidget(
        Sizer(
          builder: (_, _, _) =>
              GetMaterialApp(theme: theme, home: const ArticleScreen()),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(
        find.textContaining('Constant go-mode'),
        findsOneWidget,
      );
    });
  });
}
