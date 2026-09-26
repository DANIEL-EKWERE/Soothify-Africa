import 'explore_destination.dart';
import 'library_section.dart';

/// One run of text in an article's closing call to action.
///
/// The frames set part of that paragraph in blue and leave the rest black, so
/// it is a sequence of runs rather than one string — a plain `Text` cannot
/// carry the links, and splitting on the link text at render time would break
/// the moment a phrase repeated.
class ArticleRun {
  const ArticleRun(this.text, {this.link});

  final String text;

  /// Where the blue run goes. Null for the plain runs between them.
  final ArticleLink? link;

  bool get isLink => link != null;
}

/// What a link in an article opens. The frames underline nothing and name no
/// destination, but both phrases say plainly what they do.
enum ArticleLink {
  /// "Explore our complete Pilates & Core library".
  library,

  /// "Book a 1-on-1 session with a certified core specialist".
  booking,
}

/// A written piece — Figma "Pilates & Core Articles" (`259:58647`) and
/// "Stretch Articles" (`259:58687`).
///
/// Two frames, structurally identical: a cover, a title with its rating, a
/// body paragraph, then a call to action carrying two links.
///
/// The frames' own cover is a stock poster mock-up reading "POSTER A4 /
/// Plastic Surgery" — placeholder art, not this app's content, so each
/// article draws its section's own photograph instead. That is the same
/// resolution [LibrarySection.artPath] makes, and for the same reason.
enum Article {
  core(
    section: LibrarySection.meditation,
    title: 'Why Your Core is More Than Just Six-Pack Abs',
    rating: 4.8,
    body: 'True core strength runs deep, wrapping around your spine like a '
        'natural corset to protect your lower back and improve posture. When '
        'your transverse abdominis is weak, everyday movements like lifting '
        'or twisting put excess pressure on your joints. True stability '
        'starts from the inside out through controlled, mindful movement.',
    callToAction: [
      ArticleRun('Ready to build real strength? '),
      ArticleRun('Explore our complete Pilates & Core library',
          link: ArticleLink.library),
      ArticleRun(' or '),
      ArticleRun('Book a 1-on-1 session with a certified core specialist',
          link: ArticleLink.booking),
      ArticleRun(' to get a tailored routine.'),
    ],
  ),
  rest(
    section: LibrarySection.balance,
    title: 'The Physiology of Deep Rest: Why Doing Nothing is Productive',
    rating: 4.8,
    body: 'Constant go-mode keeps your nervous system trapped in a chronic '
        'state of fight-or-flight, flooding your body with cortisol and '
        'blocking muscle recovery. True rest triggers your parasympathetic '
        'nervous system, lowering your heart rate, repairing muscle tissue, '
        'and clearing brain fog so you can perform at your best.',
    callToAction: [
      ArticleRun('Unwind right now with our '),
      ArticleRun('Stretch & Restore evening relaxation flow',
          link: ArticleLink.library),
      ArticleRun(' or '),
      ArticleRun('Book a restorative wellness session with a licensed '
          'counselor', link: ArticleLink.booking),
      ArticleRun('.'),
    ],
  );

  const Article({
    required this.section,
    required this.title,
    required this.rating,
    required this.body,
    required this.callToAction,
  });

  /// Which library this belongs to. Decides the cover art and where the
  /// "explore the library" link lands.
  final LibrarySection section;

  final String title;

  /// Out of 5, beside the title. Both frames print 4.8.
  final double rating;

  final String body;

  final List<ArticleRun> callToAction;

  String get coverAsset => switch (section) {
        LibrarySection.meditation => ExploreDestination.meditation.assetPath,
        LibrarySection.balance => ExploreDestination.balance.assetPath,
      };
}
