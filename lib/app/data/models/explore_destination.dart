/// The three tiles under "Explore" on the Home screen.
///
/// Fixed destinations, not content categories — an earlier interim build wired
/// these to the repository's categories, which was wrong. Each has its own
/// section in the design ("HOME SCREEN --> Meditation", "--> Schedule",
/// "--> balance"), so the routes land as those screens are built.
enum ExploreDestination {
  meditation('Pilates & Core', 'assets/images/explore/meditation.png', 56),
  scheduleSession('Book a licensed Expert', 'assets/images/explore/schedule.png', 56),
  balance('Stretch & Restore', 'assets/images/explore/balance.png', 64);

  const ExploreDestination(this.label, this.assetPath, this.artSize);

  final String label;
  final String assetPath;

  /// Stretch & Restore's illustration is drawn larger than the other two.
  final double artSize;
}
