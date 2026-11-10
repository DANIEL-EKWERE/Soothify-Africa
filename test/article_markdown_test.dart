import 'package:flutter_test/flutter_test.dart';

import 'package:soothifyafrica/app/data/models/article_body.dart';

/// The small slice of Markdown an article may be written in.
///
/// The dashboard offers exactly these and the reader draws exactly these,
/// so the set is deliberately closed. Most of this is about what happens to
/// text that is *nearly* markup, because that is what authors actually
/// type.
void main() {
  group('emphasis', () {
    test('bold and italic', () {
      final spans = parseArticleBody('Runs **deep**, and *slowly*.');
      expect(spans.map((s) => s.text), ['Runs ', 'deep', ', and ', 'slowly', '.']);
      expect(spans[1].bold, isTrue);
      expect(spans[3].italic, isTrue);
    });

    test('underscores work the same way', () {
      expect(parseArticleBody('__a__')[0].bold, isTrue);
      expect(parseArticleBody('_a_')[0].italic, isTrue);
    });

    test('double markers are never read as two singles', () {
      final spans = parseArticleBody('**bold**');
      expect(spans, hasLength(1));
      expect(spans.single.bold, isTrue);
      expect(spans.single.italic, isFalse);
      expect(spans.single.text, 'bold');
    });

    test('an unclosed marker is left as typed', () {
      // Somebody writing "2 * 3" or a lone asterisk for a footnote.
      expect(parseArticleBody('2 * 3 = 6').single.text, '2 * 3 = 6');
      expect(parseArticleBody('a *b').single.text, 'a *b');
    });

    test('plain prose is one plain span', () {
      final spans = parseArticleBody('Nothing special here.');
      expect(spans, hasLength(1));
      expect(spans.single.isPlain, isTrue);
    });
  });

  group('emphasis and links together', () {
    test('a whole link can be bold', () {
      final spans = parseArticleBody('Read [**this**](media:4) now.');
      final link = spans.firstWhere((s) => s.isLink);
      expect(link.text, 'this');
      expect(link.bold, isTrue);
      expect(link.tap, const ArticleTap(ArticleTarget.media, id: '4'));
    });

    test('emphasis around a link is kept apart from it', () {
      final spans = parseArticleBody('**Really** [go](media:4).');
      expect(spans.first.bold, isTrue);
      expect(spans.first.isLink, isFalse);
      expect(spans.firstWhere((s) => s.isLink).bold, isFalse);
    });

    test('an empty link text is not a link', () {
      expect(parseArticleBody('[](media:4)').single.isLink, isFalse);
    });
  });

  group('blocks', () {
    test('an empty body is no blocks', () {
      expect(parseArticleBlocks(''), isEmpty);
      expect(parseArticleBlocks('   \n  \n'), isEmpty);
    });

    test('a body with no markup is the one paragraph it reads as', () {
      final blocks = parseArticleBlocks('Just some prose.');
      expect(blocks, hasLength(1));
      expect(blocks.single, isA<ArticleParagraph>());
    });

    test('a blank line separates paragraphs', () {
      final blocks = parseArticleBlocks('One.\n\nTwo.');
      expect(blocks, hasLength(2));
      expect(blocks.every((b) => b is ArticleParagraph), isTrue);
    });

    test('a wrapped line is one paragraph, not two', () {
      // The editor hard-wraps; the author did not ask for a line break.
      final blocks = parseArticleBlocks('One line\nand its continuation.');
      expect(blocks, hasLength(1));
      final p = blocks.single as ArticleParagraph;
      expect(p.spans.map((s) => s.text).join(), 'One line and its continuation.');
    });

    test('headings at both levels', () {
      final blocks = parseArticleBlocks('## Two\n\n### Three');
      expect((blocks[0] as ArticleHeading).level, 2);
      expect((blocks[1] as ArticleHeading).level, 3);
      expect((blocks[0] as ArticleHeading).spans.single.text, 'Two');
    });

    test('a single hash is not a heading', () {
      // The article's own title is the first level; a body heading must not
      // compete with it, so `#` is left as prose.
      expect(parseArticleBlocks('# Nope'), [isA<ArticleParagraph>()]);
    });

    test('a hash mid-sentence is not a heading', () {
      final blocks = parseArticleBlocks('Tagged ## like this');
      expect(blocks.single, isA<ArticleParagraph>());
    });

    test('consecutive bullets are one list', () {
      final blocks = parseArticleBlocks('- one\n- two\n- three');
      expect(blocks, hasLength(1));
      final list = blocks.single as ArticleList;
      expect(list.ordered, isFalse);
      expect(list.items, hasLength(3));
      expect(list.items[1].single.text, 'two');
    });

    test('numbered lists', () {
      final list = parseArticleBlocks('1. one\n2. two').single as ArticleList;
      expect(list.ordered, isTrue);
      expect(list.items, hasLength(2));
    });

    test('a numbered list under a bulleted one is two lists', () {
      final blocks = parseArticleBlocks('- a\n1. b');
      expect(blocks, hasLength(2));
      expect((blocks[0] as ArticleList).ordered, isFalse);
      expect((blocks[1] as ArticleList).ordered, isTrue);
    });

    test('a list ends where prose begins', () {
      final blocks = parseArticleBlocks('- a\n- b\nThen prose.');
      expect(blocks, hasLength(2));
      expect(blocks[0], isA<ArticleList>());
      expect(blocks[1], isA<ArticleParagraph>());
    });

    test('bullets carry links and emphasis', () {
      final list = parseArticleBlocks(
        '- Try [this](media:7)\n- Or **that**',
      ).single as ArticleList;
      // "Try " and the link are two runs, so this is not a `.single`.
      expect(list.items[0].firstWhere((s) => s.isLink).tap!.id, '7');
      expect(list.items[0].map((s) => s.text).join(), 'Try this');
      expect(list.items[1].firstWhere((s) => s.bold).text, 'that');
    });

    test('a hyphen in a sentence is not a bullet', () {
      final blocks = parseArticleBlocks('Well-being matters.');
      expect(blocks.single, isA<ArticleParagraph>());
    });

    test('the whole lot together, in order', () {
      final blocks = parseArticleBlocks('''
## Why your core matters

True strength runs **deep**.

- Start slow
- Breathe out on effort

Wind down with [Deep Rest](media:42).
''');
      expect(blocks.map((b) => b.runtimeType.toString()), [
        'ArticleHeading',
        'ArticleParagraph',
        'ArticleList',
        'ArticleParagraph',
      ]);
    });
  });

  group('images', () {
    test('an image on its own line is a block', () {
      final blocks = parseArticleBlocks('![A mat](https://x/y.jpg)');
      final image = blocks.single as ArticleImage;
      expect(image.url, 'https://x/y.jpg');
      expect(image.alt, 'A mat');
    });

    test('the alt text may be empty', () {
      expect((parseArticleBlocks('![](https://x/y.jpg)').single
              as ArticleImage)
          .alt, '');
    });

    test('an image separates the paragraphs around it', () {
      final blocks = parseArticleBlocks(
        'Before.\n\n![](https://x/y.jpg)\n\nAfter.',
      );
      expect(blocks.map((b) => b.runtimeType.toString()), [
        'ArticleParagraph',
        'ArticleImage',
        'ArticleParagraph',
      ]);
    });

    test('an image mid-sentence is left as typed, not dropped', () {
      // Dropping it would lose the author's words with no sign anything
      // had happened.
      final spans = parseArticleBody('See ![a mat](https://x/y.jpg) here.');
      expect(spans.map((s) => s.text).join(), contains('![a mat]'));
      expect(spans.any((s) => s.isLink), isFalse);
    });
  });

  group('what the reader must never show', () {
    test('no syntax survives into the text', () {
      const body = '## Heading\n\n**Bold** and [a link](media:1).\n\n- bullet';
      final shown = parseArticleBlocks(body)
          .map((b) => switch (b) {
                ArticleHeading(:final spans) => spans.map((s) => s.text).join(),
                ArticleParagraph(:final spans) =>
                  spans.map((s) => s.text).join(),
                ArticleList(:final items) =>
                  items.map((i) => i.map((s) => s.text).join()).join(),
                ArticleImage() => '',
              })
          .join(' ');

      for (final mark in ['##', '**', '](', 'media:1', '- ']) {
        expect(shown, isNot(contains(mark)), reason: mark);
      }
      expect(shown, contains('Heading'));
      expect(shown, contains('Bold'));
      expect(shown, contains('a link'));
      expect(shown, contains('bullet'));
    });
  });
}
