/// Links written into an article's body, and how they are read back out.
///
/// An article is written on the media dashboard, in a plain text field, by
/// somebody who is not going to learn a markup language for it. So the
/// syntax is the one everybody already knows:
///
///     Wind down with [our Deep Rest sleep story](media:42) tonight, or
///     [watch the evening flow](media:17) first.
///
/// Anything that is not a well-formed link is left exactly as typed --
/// including a stray bracket, which a reader is far more likely to have
/// meant literally than as a broken link. Nothing here throws.
///
/// The targets, after the colon:
///
///   `media:<id>`    one piece of content -- a sleep story, a video, an
///                   audio session. The id is the media id on the server.
///   `article:<id>`  another written piece. Same thing underneath; named
///                   separately because it reads better in the source.
///   `library`       the library this article belongs to.
///   `booking`       book a one-on-one.
///   `breathe`       the breathing minute.
///   `http(s)://`    anything outside the app.
library;

/// What a link in an article body points at.
enum ArticleTarget {
  /// A piece of content, by id. Opens the player.
  media,

  /// The library section this article belongs to.
  library,

  /// Booking a one-on-one.
  booking,

  /// The breathing exercise.
  breathe,

  /// A web address. Leaves the app.
  external,
}

/// One link, parsed.
class ArticleTap {
  const ArticleTap(this.target, {this.id = ''});

  final ArticleTarget target;

  /// The media id for [ArticleTarget.media], or the URL for
  /// [ArticleTarget.external]. Empty for the rest.
  final String id;

  /// Reads the part inside the brackets. Null when it names nothing known,
  /// which leaves the whole link as plain text rather than offering the
  /// reader something that does nothing when tapped.
  static ArticleTap? parse(String destination) {
    final raw = destination.trim();
    if (raw.isEmpty) return null;

    final lower = raw.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return ArticleTap(ArticleTarget.external, id: raw);
    }

    final colon = raw.indexOf(':');
    final scheme = (colon < 0 ? raw : raw.substring(0, colon)).toLowerCase();
    final rest = colon < 0 ? '' : raw.substring(colon + 1).trim();

    switch (scheme) {
      // `article:` and `media:` are the same lookup. Both spellings exist
      // because an author writing a link to a piece of writing should not
      // have to call it media.
      case 'media':
      case 'article':
      case 'content':
        return rest.isEmpty ? null : ArticleTap(ArticleTarget.media, id: rest);
      case 'library':
        return const ArticleTap(ArticleTarget.library);
      case 'booking':
      case 'book':
        return const ArticleTap(ArticleTarget.booking);
      case 'breathe':
      case 'breathing':
        return const ArticleTap(ArticleTarget.breathe);
      default:
        return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is ArticleTap && other.target == target && other.id == id;

  @override
  int get hashCode => Object.hash(target, id);

  @override
  String toString() => 'ArticleTap($target, $id)';
}

/// A stretch of an article's body: words, with or without emphasis, and
/// with or without a link on them.
class ArticleSpan {
  const ArticleSpan(
    this.text, {
    this.tap,
    this.bold = false,
    this.italic = false,
  });

  final String text;

  /// Null for prose that is not a link.
  final ArticleTap? tap;

  final bool bold;
  final bool italic;

  bool get isLink => tap != null;
  bool get isPlain => tap == null && !bold && !italic;

  ArticleSpan copyWith({bool? bold, bool? italic}) => ArticleSpan(
        text,
        tap: tap,
        bold: bold ?? this.bold,
        italic: italic ?? this.italic,
      );

  @override
  bool operator ==(Object other) =>
      other is ArticleSpan &&
      other.text == text &&
      other.tap == tap &&
      other.bold == bold &&
      other.italic == italic;

  @override
  int get hashCode => Object.hash(text, tap, bold, italic);

  @override
  String toString() {
    final marks = [if (bold) 'b', if (italic) 'i'].join();
    final body = marks.isEmpty ? text : '<$marks>$text';
    return isLink ? '[$body]($tap)' : body;
  }
}

// ---------------------------------------------------------------------
// Blocks
// ---------------------------------------------------------------------

/// One block of an article: a paragraph, a heading, a list or a picture.
///
/// Blocks rather than one long string of spans, because a heading and a
/// bullet are laid out, not merely styled -- they need their own spacing,
/// their own width and, for a bullet, something drawn in the margin.
sealed class ArticleBlock {
  const ArticleBlock();
}

/// Ordinary prose.
class ArticleParagraph extends ArticleBlock {
  const ArticleParagraph(this.spans);

  final List<ArticleSpan> spans;

  @override
  String toString() => 'p(${spans.join()})';
}

/// A section heading. [level] is 2 or 3 -- the article's own title is the
/// first level, so a body heading never competes with it.
class ArticleHeading extends ArticleBlock {
  const ArticleHeading(this.level, this.spans);

  final int level;
  final List<ArticleSpan> spans;

  @override
  String toString() => 'h$level(${spans.join()})';
}

/// A run of bullets or numbers. Kept as one block rather than a block per
/// item, so the gap between two bullets is not the gap between paragraphs.
class ArticleList extends ArticleBlock {
  const ArticleList({required this.ordered, required this.items});

  final bool ordered;
  final List<List<ArticleSpan>> items;

  @override
  String toString() =>
      '${ordered ? 'ol' : 'ul'}(${items.map((i) => i.join()).join('|')})';
}

/// A table: one header row, then the body rows.
///
/// Every row has exactly as many cells as the header. A row typed with too
/// few is padded with empty cells and one with too many is cut, so the
/// grid the reader sees is always square -- a ragged table is a layout the
/// screen cannot draw sensibly.
class ArticleTable extends ArticleBlock {
  const ArticleTable({required this.header, required this.rows});

  final List<List<ArticleSpan>> header;
  final List<List<List<ArticleSpan>>> rows;

  int get columns => header.length;

  @override
  String toString() =>
      'table(${header.map((c) => c.join()).join('|')} / ${rows.length} rows)';
}

/// A picture inside the body, as opposed to the article's cover.
class ArticleImage extends ArticleBlock {
  const ArticleImage(this.url, {this.alt = ''});

  final String url;

  /// What a screen reader says, and what is shown if the picture will not
  /// load. Optional, as it is in the syntax.
  final String alt;

  @override
  String toString() => 'img($url)';
}

// ---------------------------------------------------------------------
// Parsing
// ---------------------------------------------------------------------

/// `[text](destination)`.
///
/// The text may not contain a bracket of its own and the destination may
/// not contain a paren or a space, which keeps a stray bracket in ordinary
/// prose from swallowing the rest of a paragraph.
final _link = RegExp(r'(!?)\[([^\[\]]*)\]\(([^()\s]+)\)');

/// `**bold**` and `*italic*`, longest marker first so `**` is never read as
/// two singles.
final _emphasis = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|__(.+?)__|_(.+?)_');

/// Splits one line of prose into runs: plain, emphasised, and links.
///
/// Returns a single plain span for a line with no markup in it, so a caller
/// never has to special-case the ordinary sentence.
///
/// Deliberately a small subset of Markdown, not the whole of it. The
/// dashboard offers exactly these and the reader draws exactly these, so
/// there is no syntax that looks supported and is not.
List<ArticleSpan> parseArticleBody(String body) {
  if (body.isEmpty) return const [];

  final spans = <ArticleSpan>[];
  var at = 0;

  for (final match in _link.allMatches(body)) {
    // An image is a block, not an inline run. One written mid-sentence is
    // left as typed rather than silently dropped, so the author sees it.
    if (match.group(1) == '!') continue;

    final tap = ArticleTap.parse(match.group(3)!);
    // Not a destination we know: leave the whole thing as the author typed
    // it. A blue phrase that does nothing is worse than visible syntax,
    // because only one of the two tells anybody something is wrong.
    if (tap == null) continue;

    final text = match.group(2)!;
    if (text.isEmpty) continue;

    if (match.start > at) {
      spans.addAll(_emphasised(body.substring(at, match.start)));
    }
    // Emphasis inside a link is read too: a whole link is often bold.
    for (final run in _emphasised(text)) {
      spans.add(ArticleSpan(run.text,
          tap: tap, bold: run.bold, italic: run.italic));
    }
    at = match.end;
  }

  if (at < body.length) {
    spans.addAll(_emphasised(body.substring(at)));
  }
  return spans;
}

/// Splits prose on `**bold**` and `*italic*`.
List<ArticleSpan> _emphasised(String text) {
  if (text.isEmpty) return const [];

  final spans = <ArticleSpan>[];
  var at = 0;

  for (final match in _emphasis.allMatches(text)) {
    if (match.start > at) {
      spans.add(ArticleSpan(text.substring(at, match.start)));
    }
    // Groups 1 and 3 are the double markers, 2 and 4 the single ones.
    final strong = match.group(1) ?? match.group(3);
    final slant = match.group(2) ?? match.group(4);
    spans.add(
      strong != null
          ? ArticleSpan(strong, bold: true)
          : ArticleSpan(slant!, italic: true),
    );
    at = match.end;
  }

  if (at < text.length) spans.add(ArticleSpan(text.substring(at)));
  return spans;
}

final _heading = RegExp(r'^(#{2,3})\s+(.*)$');
final _bullet = RegExp(r'^\s*[-*+]\s+(.*)$');
final _numbered = RegExp(r'^\s*\d+[.)]\s+(.*)$');
final _imageLine = RegExp(r'^!\[([^\[\]]*)\]\(([^()\s]+)\)$');

/// `| --- | :---: | ---: |` -- the line under a table's header.
///
/// What makes a table a table. A line with a pipe in it is ordinary prose
/// unless the next line is one of these, so "Pilates | Yoga" written in a
/// sentence stays a sentence.
final _tableRule = RegExp(r'^\s*\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)*\|?\s*$');

/// The cells of one row, with the pipes at either end dropped.
List<String> _cellsOf(String line) {
  var row = line.trim();
  if (row.startsWith('|')) row = row.substring(1);
  if (row.endsWith('|')) row = row.substring(0, row.length - 1);
  return row.split('|').map((cell) => cell.trim()).toList();
}

bool _isTableRow(String line) => line.trim().isNotEmpty && line.contains('|');

/// Reads a body into the blocks the reader lays out.
///
/// A blank line ends a block; consecutive bullets are gathered into one
/// list. Anything that is not a heading, a bullet or a picture is prose,
/// which means a body written with no markup at all comes back as the one
/// paragraph it reads as.
List<ArticleBlock> parseArticleBlocks(String body) {
  if (body.trim().isEmpty) return const [];

  final blocks = <ArticleBlock>[];
  final paragraph = <String>[];
  List<List<ArticleSpan>>? items;
  var ordered = false;

  void closeParagraph() {
    if (paragraph.isEmpty) return;
    // Joined with a space, not a newline: a hard wrap in the editor is a
    // line break the author did not ask for.
    blocks.add(ArticleParagraph(parseArticleBody(paragraph.join(' '))));
    paragraph.clear();
  }

  void closeList() {
    if (items == null) return;
    blocks.add(ArticleList(ordered: ordered, items: items!));
    items = null;
  }

  void close() {
    closeParagraph();
    closeList();
  }

  final lines = body.split('\n');
  for (var at = 0; at < lines.length; at++) {
    final line = lines[at].trimRight();

    if (line.trim().isEmpty) {
      close();
      continue;
    }

    // A header row, then the rule under it, then rows until a line with
    // no pipe in it.
    if (_isTableRow(line) &&
        at + 1 < lines.length &&
        _tableRule.hasMatch(lines[at + 1])) {
      close();
      final header = _cellsOf(line);
      final rows = <List<List<ArticleSpan>>>[];
      at += 2;
      while (at < lines.length && _isTableRow(lines[at])) {
        final cells = _cellsOf(lines[at]);
        rows.add([
          for (var c = 0; c < header.length; c++)
            parseArticleBody(c < cells.length ? cells[c] : ''),
        ]);
        at++;
      }
      // The loop's own increment would skip the line that ended the table.
      at--;
      blocks.add(ArticleTable(
        header: [for (final cell in header) parseArticleBody(cell)],
        rows: rows,
      ));
      continue;
    }

    final image = _imageLine.firstMatch(line.trim());
    if (image != null) {
      close();
      blocks.add(ArticleImage(image.group(2)!, alt: image.group(1) ?? ''));
      continue;
    }

    final heading = _heading.firstMatch(line);
    if (heading != null) {
      close();
      blocks.add(ArticleHeading(
        heading.group(1)!.length,
        parseArticleBody(heading.group(2)!.trim()),
      ));
      continue;
    }

    final bullet = _bullet.firstMatch(line);
    final numbered = bullet == null ? _numbered.firstMatch(line) : null;
    if (bullet != null || numbered != null) {
      final wantsOrdered = numbered != null;
      // A numbered list directly under a bulleted one is two lists, not a
      // list that changes its mind halfway down.
      if (items != null && ordered != wantsOrdered) closeList();
      closeParagraph();
      ordered = wantsOrdered;
      items ??= <List<ArticleSpan>>[];
      items!.add(parseArticleBody((bullet ?? numbered)!.group(1)!.trim()));
      continue;
    }

    closeList();
    paragraph.add(line.trim());
  }

  close();
  return blocks;
}
