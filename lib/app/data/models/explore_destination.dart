/// The three tiles under "Explore" on the Home screen.
///
/// Fixed destinations, not content categories — an earlier interim build wired
/// these to the repository's categories, which was wrong. Each has its own
/// section in the design ("HOME SCREEN --> Meditation", "--> Schedule",
/// "--> balance"), so the routes land as those screens are built.
enum ExploreDestination {
  // Photographs now, filling the tile — Figma "Home screen/signed in"
  // (page 124:2, `191:5489`). The illustrated badges the tiles used to carry
  // are still used elsewhere (the Check-Ins cards, the library header), so
  // they stay under their old names and these are new files.
  meditation('Pilates & Core', 'assets/images/explore/pilates_core.jpg'),
  scheduleSession(
    'Book a Licensed Expert',
    'assets/images/explore/book_expert.jpg',
  ),
  balance('Stretch & Restore', 'assets/images/explore/stretch_restore.jpg');

  const ExploreDestination(this.label, this.assetPath);

  final String label;

  /// A photo that covers the 100x90 tile.
  final String assetPath;
}
