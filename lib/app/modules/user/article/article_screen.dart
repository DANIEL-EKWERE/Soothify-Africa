import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/article.dart';
import '../../../data/models/article_body.dart';
import 'controller/article_controller.dart';

/// The article reader — Figma "Pilates & Core Articles" (`259:58647`) and
/// "Stretch Articles" (`259:58687`).
///
/// Measured below the status bar: the header 69, the cover 123 (318 tall,
/// 344 wide), the title 465.5 over two lines at a 32 pitch with the rating
/// on its first line, the body 535 at a 19 pitch, and the call to action 692.
///
/// The frames' own cover is a stock poster mock-up ("POSTER A4 / Plastic
/// Surgery"), so the article's own cover is drawn -- whatever was uploaded
/// with it.
class ArticleScreen extends GetView<ArticleController> {
  const ArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 22.v),
            const _Header(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 40.v, 24.h, 32.v),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.h),
                    child: CustomImageView(
                      imagePath: controller.cover,
                      height: 318.v,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 24.5.v),
                  const _TitleRow(),
                  SizedBox(height: 22.5.v),
                  const _Body(),
                  SizedBox(height: 33.v),
                  const _CallToAction(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Row(
        children: [
          InkWell(
            onTap: Get.back,
            child: CustomImageView(
              imagePath: ImageConstant.icBack,
              height: 18.h,
              width: 18.h,
              color: appTheme.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              'Articles',
              textAlign: TextAlign.center,
              style: CustomTextStyles.appBarTitle,
            ),
          ),
          SizedBox(width: 18.h),
        ],
      ),
    );
  }
}

/// The title wrapping under a rating pinned to the first line's right.
///
/// The frames set the rating beside the title rather than above it, so the
/// title has to flow around it — hence the leading inline space rather than a
/// Row, which would reserve the rating's width on every line.
class _TitleRow extends StatelessWidget {
  const _TitleRow();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 84.h),
          child: Text(Get.find<ArticleController>().title,
              style: CustomTextStyles.articleTitle),
        ),
        Positioned(
          right: 0,
          top: 4.v,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomImageView(
                imagePath: ImageConstant.icStar,
                height: 16.h,
                width: 16.h,
                color: appTheme.accent,
              ),
              SizedBox(width: 6.h),
              Text(
                '${Get.find<ArticleController>().rating}/5',
                style: CustomTextStyles.articleRating,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The article itself, laid out block by block.
///
/// An author writes it on the dashboard in a small slice of Markdown --
/// headings, bold, italic, bullets, numbers, pictures, and links to other
/// content:
///
///     ## Why your core matters
///
///     True strength runs **deep**. Wind down with
///     [our Deep Rest story](media:42) tonight.
///
/// Blocks rather than one long rich string, because a heading and a bullet
/// are laid out, not merely styled: each needs its own spacing, and a
/// bullet needs something drawn in the margin.
class _Body extends StatelessWidget {
  const _Body();

  /// The gap above each kind of block. Not one uniform rhythm: a heading
  /// needs room above it to belong to what follows rather than to what
  /// came before, and two bullets are closer than two paragraphs.
  double _gapAbove(ArticleBlock block, ArticleBlock? previous) {
    if (previous == null) return 0;
    return switch (block) {
      ArticleHeading() => 26,
      ArticleImage() => 20,
      ArticleTable() => 18,
      _ => previous is ArticleHeading ? 10 : 16,
    };
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticleController>();
    final blocks = controller.bodyBlocks;

    // Nothing written. The reader shows the cover and the title rather than
    // an empty space where the words should be.
    if (blocks.isEmpty) return const SizedBox.shrink();

    ArticleBlock? previous;
    final children = <Widget>[];
    for (final block in blocks) {
      final gap = _gapAbove(block, previous);
      if (gap > 0) children.add(SizedBox(height: gap.v));
      children.add(_blockWidget(block, controller));
      previous = block;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _blockWidget(ArticleBlock block, ArticleController controller) {
    return switch (block) {
      ArticleParagraph(:final spans) => _LinkedProse(
          spans: spans,
          onTap: controller.followTap,
        ),
      ArticleHeading(:final level, :final spans) => _LinkedProse(
          spans: spans,
          onTap: controller.followTap,
          style: level == 2
              ? CustomTextStyles.articleHeading2
              : CustomTextStyles.articleHeading3,
        ),
      ArticleList(:final ordered, :final items) => _List(
          ordered: ordered,
          items: items,
          onTap: controller.followTap,
        ),
      ArticleImage(:final url, :final alt) => _BodyImage(url: url, alt: alt),
      ArticleTable() => _BodyTable(table: block, onTap: controller.followTap),
    };
  }
}

/// Bullets or numbers.
///
/// A Column of Rows rather than a bulleted Text: the marker sits in its own
/// column so that a item wrapping onto a second line lines up under the
/// first word, not under the bullet.
class _List extends StatelessWidget {
  const _List({
    required this.ordered,
    required this.items,
    required this.onTap,
  });

  final bool ordered;
  final List<List<ArticleSpan>> items;
  final void Function(ArticleTap) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: 8.v),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22.h,
                child: Text(
                  ordered ? '${i + 1}.' : '•',
                  style: CustomTextStyles.articleBody,
                ),
              ),
              Expanded(
                child: _LinkedProse(spans: items[i], onTap: onTap),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// A table in the body.
///
/// Fills the width when its columns fit, and scrolls sideways when they do
/// not. Squeezing six columns into a phone's width gives each one a word
/// per line, which is a table nobody can read; a table that scrolls is one
/// they can.
class _BodyTable extends StatelessWidget {
  const _BodyTable({required this.table, required this.onTap});

  final ArticleTable table;
  final void Function(ArticleTap) onTap;

  /// The narrowest a column may be before the table scrolls instead.
  static const minColumn = 104.0;

  /// The width each column is given once it scrolls.
  static const scrollingColumn = 140.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final fits = table.columns * minColumn.h <= constraints.maxWidth;
      final grid = Table(
        defaultColumnWidth: fits
            ? const FlexColumnWidth()
            : FixedColumnWidth(scrollingColumn.h),
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        border: TableBorder(
          horizontalInside: BorderSide(color: appTheme.cardBorder),
          verticalInside: BorderSide(color: appTheme.cardBorder),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(color: appTheme.surfaceAlt),
            children: [
              for (final cell in table.header)
                _cell(cell, CustomTextStyles.articleTableHead),
            ],
          ),
          for (final row in table.rows)
            TableRow(children: [
              for (final cell in row)
                _cell(cell, CustomTextStyles.articleTableCell),
            ]),
        ],
      );

      final framed = Container(
        decoration: BoxDecoration(
          border: Border.all(color: appTheme.cardBorder),
          borderRadius: BorderRadius.circular(10.h),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.h),
          child: grid,
        ),
      );

      return fits
          ? framed
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: table.columns * scrollingColumn.h,
                child: framed,
              ),
            );
    });
  }

  Widget _cell(List<ArticleSpan> spans, TextStyle style) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 9.v),
        child: _LinkedProse(spans: spans, onTap: onTap, style: style),
      );
}

/// A picture partway through the body, with its alt text as a caption.
///
/// Optional in the syntax and optional in fact: a picture that will not
/// load leaves the article readable rather than a broken box in the middle
/// of it.
class _BodyImage extends StatelessWidget {
  const _BodyImage({required this.url, required this.alt});

  final String url;
  final String alt;

  /// Sixteen by nine, and a definite box rather than none.
  ///
  /// Without a height this drew at zero: `CustomImageView` hands its own
  /// height straight to the placeholder, and a placeholder of height null
  /// inside a Column has unbounded height to fill and so fills none of it.
  /// The picture was in the body, parsed, and 342 by 0 on the screen.
  ///
  /// A ratio rather than a fixed height so it holds on every screen width,
  /// and it also means the space is reserved while the picture loads --
  /// the text below does not jump when it arrives.
  static const ratio = 16 / 9;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.h),
          child: AspectRatio(
            aspectRatio: ratio,
            child: CustomImageView(
              imagePath: url,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (alt.isNotEmpty) ...[
          SizedBox(height: 8.v),
          Text(alt, style: CustomTextStyles.articleCaption),
        ],
      ],
    );
  }
}

/// The closing paragraph, with its two phrases tappable.
class _CallToAction extends StatelessWidget {
  const _CallToAction();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticleController>();
    return _LinkedProse(
      // The generated call to action carries [ArticleLink]s rather than
      // body taps, so it is mapped onto the same shape -- one widget draws
      // both, and there is one place where a recognizer can leak.
      spans: [
        for (final run in controller.callToAction)
          ArticleSpan(
            run.text,
            tap: switch (run.link) {
              ArticleLink.library => const ArticleTap(ArticleTarget.library),
              ArticleLink.booking => const ArticleTap(ArticleTarget.booking),
              null => null,
            },
          ),
      ],
      onTap: controller.followTap,
    );
  }
}

/// Prose with tappable phrases in it.
///
/// Stateful only because a [TapGestureRecognizer] has to be disposed — one
/// built inline in `build` leaks a recognizer on every rebuild.
class _LinkedProse extends StatefulWidget {
  const _LinkedProse({required this.spans, required this.onTap, this.style});

  final List<ArticleSpan> spans;
  final void Function(ArticleTap) onTap;

  /// What the plain runs are set in. Body copy unless a heading says
  /// otherwise -- emphasis and links are applied on top of whatever this
  /// is, so a bold word inside a heading stays heading-sized.
  final TextStyle? style;

  @override
  State<_LinkedProse> createState() => _LinkedProseState();
}

class _LinkedProseState extends State<_LinkedProse> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void initState() {
    super.initState();
    _build();
  }

  @override
  void didUpdateWidget(_LinkedProse old) {
    super.didUpdateWidget(old);
    // The spans can change under us -- a different article pushed onto the
    // same route. Recognizers are rebuilt rather than reused, or a tap
    // would follow the previous article's link.
    if (widget.spans.length != old.spans.length) {
      _dispose();
      _build();
    }
  }

  void _build() {
    for (final span in widget.spans) {
      final tap = span.tap;
      if (tap == null) continue;
      _recognizers.add(
        TapGestureRecognizer()..onTap = () => widget.onTap(tap),
      );
    }
  }

  void _dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.style ?? CustomTextStyles.articleBody;
    var next = 0;
    return Text.rich(
      TextSpan(
        children: [
          for (final span in widget.spans)
            TextSpan(
              text: span.text,
              style: _styleFor(span, base),
              recognizer: span.isLink ? _recognizers[next++] : null,
            ),
        ],
      ),
    );
  }

  /// Emphasis and link colour applied on top of the block's own style,
  /// rather than replacing it -- a bold word in a heading has to stay
  /// heading-sized, and a link in a bullet has to stay body-sized.
  TextStyle _styleFor(ArticleSpan span, TextStyle base) {
    var style = base;
    if (span.isLink) style = style.copyWith(color: appTheme.soothifyBlue);
    if (span.bold) {
      style = style.copyWith(
        fontWeight: FontWeight.w700,
        fontVariations: const [FontVariation('wght', 700)],
      );
    }
    if (span.italic) style = style.copyWith(fontStyle: FontStyle.italic);
    return style;
  }
}
