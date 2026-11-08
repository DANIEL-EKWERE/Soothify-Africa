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

/// A stretch of an article's body: plain words, or a link.
class ArticleSpan {
  const ArticleSpan(this.text, {this.tap});

  final String text;

  /// Null for plain prose.
  final ArticleTap? tap;

  bool get isLink => tap != null;

  @override
  String toString() => isLink ? '[$text]($tap)' : text;
}

/// Splits a body into plain runs and links.
///
/// Returns a single plain span for a body with no links in it, so a caller
/// never has to special-case the ordinary article.
///
/// Deliberately not a general Markdown parser. Links are the only thing the
/// dashboard offers and the only thing the reader renders, so bold, headings
/// and images would all be syntax that looks supported and is not.
List<ArticleSpan> parseArticleBody(String body) {
  if (body.isEmpty) return const [];

  // [text](destination). The text may not contain a bracket of its own and
  // the destination may not contain a paren, which keeps a stray bracket in
  // ordinary prose from swallowing the rest of the paragraph.
  final pattern = RegExp(r'\[([^\[\]]+)\]\(([^()\s]+)\)');

  final spans = <ArticleSpan>[];
  var at = 0;

  for (final match in pattern.allMatches(body)) {
    final tap = ArticleTap.parse(match.group(2)!);
    // Not a destination we know: leave the whole thing as the author typed
    // it. A blue phrase that does nothing is worse than visible syntax,
    // because only one of the two tells anybody something is wrong.
    if (tap == null) continue;

    if (match.start > at) {
      spans.add(ArticleSpan(body.substring(at, match.start)));
    }
    spans.add(ArticleSpan(match.group(1)!, tap: tap));
    at = match.end;
  }

  if (at < body.length) {
    spans.add(ArticleSpan(body.substring(at)));
  }
  return spans;
}
