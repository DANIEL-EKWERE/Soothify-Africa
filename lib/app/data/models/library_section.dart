import 'explore_destination.dart';

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

/// The closing promo card — "Pilates & Core sessions" / "Stretch & Restore sessions".
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

  /// 50 on Pilates & Core, 56 on Stretch & Restore.
  final double iconSize;
}

/// Which library the shelf screen is showing.
///
/// Meditation (Figma 135:11744) and Balance (135:20551) are the same frame
/// with different copy and blocks, so they share one screen.
enum LibrarySection {
  meditation('meditation', 'Pilates & Core', [
    LibraryShelf('Voice Overs', 'voice-overs'),
    LibraryFeature(
      heading: 'Sleep Stories',
      title: 'Sleep stories',
      body: 'Calm narratives to help you sleep better',
      asset: 'assets/images/library/sleep_stories.png',
    ),
    LibraryShelf('Sound Effects', 'sound-effects'),
    LibraryPromo(
      title: 'Pilates & Core sessions',
      body: 'Speak with a meditation therapist',
      asset: 'assets/images/library/meditation_session.png',
      iconSize: 50,
    ),
  ]),
  balance('balance', 'Stretch & Restore', [
    LibraryShelf('Yoga flow', 'yoga-flow'),
    LibraryShelf('Sounds', 'sounds'),
    LibraryPromo(
      title: 'Stretch & Restore sessions',
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
  /// Explore tile uses, so the two read as the same destination and the Hero
  /// between them flies one object rather than swapping a photo for a badge.
  ///
  /// Taken from the tile rather than spelt out here: that is what let the two
  /// drift apart once already, when the tiles became photographs and this
  /// stayed on the old badge.
  String get artPath => switch (this) {
        LibrarySection.meditation => ExploreDestination.meditation.assetPath,
        LibrarySection.balance => ExploreDestination.balance.assetPath,
      };

  Iterable<LibraryShelf> get shelves => blocks.whereType<LibraryShelf>();
}
