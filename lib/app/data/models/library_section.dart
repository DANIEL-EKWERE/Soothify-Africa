/// One block on a library screen.
///
/// The frames are not a uniform list of shelves: Meditation puts a Sleep
/// Stories *card* between two shelves and closes with a sessions promo, and
/// Balance closes with its own promo after two shelves. Modelling the page as
/// an ordered list of blocks is what lets both screens share one widget
/// without either growing a special case.
sealed class LibraryBlock {
  const LibraryBlock();
}

/// A heading with a horizontally scrolling row of cover cards.
class LibraryShelf extends LibraryBlock {
  const LibraryShelf(this.title, this.query);

  final String title;

  /// Which slice of content fills the shelf.
  final String query;
}

/// The Sleep Stories card — a heading above a single wide row.
class LibraryFeature extends LibraryBlock {
  const LibraryFeature({
    required this.heading,
    required this.title,
    required this.body,
    required this.asset,
  });

  /// The section heading above the card. The design capitalises it
  /// differently from the card's own title ("Sleep Stories" / "Sleep
  /// stories"), so both are carried rather than derived.
  final String heading;

  final String title;
  final String body;
  final String asset;
}

/// The closing promo card — "Meditation sessions" / "Balance sessions".
///
/// No section heading above it, a smaller icon, and radius 8 rather than 12.
class LibraryPromo extends LibraryBlock {
  const LibraryPromo({
    required this.title,
    required this.body,
    required this.asset,
    required this.iconSize,
  });

  final String title;
  final String body;
  final String asset;

  /// 50 on Meditation, 56 on Balance.
  final double iconSize;
}

/// Which library the shelf screen is showing.
///
/// Meditation (Figma 135:11744) and Balance (135:20551) are the same frame
/// with different copy and blocks, so they share one screen.
enum LibrarySection {
  meditation('meditation', 'Meditation', [
    LibraryShelf('Voice Overs', 'voice-overs'),
    LibraryFeature(
      heading: 'Sleep Stories',
      title: 'Sleep stories',
      body: 'Calm narratives to help you sleep better',
      asset: 'assets/images/library/sleep_stories.png',
    ),
    LibraryShelf('Sound Effects', 'sound-effects'),
    LibraryPromo(
      title: 'Meditation sessions',
      body: 'Speak with a meditation therapist',
      asset: 'assets/images/library/meditation_session.png',
      iconSize: 50,
    ),
  ]),
  balance('balance', 'Balance', [
    LibraryShelf('Yoga flow', 'yoga-flow'),
    LibraryShelf('Sounds', 'sounds'),
    LibraryPromo(
      title: 'Balance sessions',
      // The design's own leading space is dropped; it is a typo, not spacing.
      body: 'Schedule a wellness session with a coach today',
      asset: 'assets/images/library/balance_session.png',
      iconSize: 56,
    ),
  ]);

  const LibrarySection(this.id, this.title, this.blocks);

  final String id;
  final String title;
  final List<LibraryBlock> blocks;

  /// Both frames use the same placeholder.
  String get searchHint => 'Let’s find your calm';

  /// The section's own artwork, shown in its header — the same image Home's
  /// Explore tile uses, so the two read as the same destination.
  String get artPath => 'assets/images/explore/$id.png';

  Iterable<LibraryShelf> get shelves => blocks.whereType<LibraryShelf>();
}
