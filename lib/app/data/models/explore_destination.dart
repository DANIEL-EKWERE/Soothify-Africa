/// The three tiles under "Explore" on the Home screen.
///
/// Fixed destinations, not content categories — an earlier interim build wired
/// these to the repository's categories, which was wrong. Each has its own
/// section in the design ("HOME SCREEN --> Meditation", "--> Schedule",
/// "--> balance"), so the routes land as those screens are built.
enum ExploreDestination {
  meditation('Meditation', 'assets/images/explore/meditation.png', 56),
  scheduleSession('Schedule Session', 'assets/images/explore/schedule.png', 56),
  balance('Balance', 'assets/images/explore/balance.png', 64);

  const ExploreDestination(this.label, this.assetPath, this.artSize);

  final String label;
  final String assetPath;

  /// Balance's illustration is drawn larger than the other two.
  final double artSize;
}
