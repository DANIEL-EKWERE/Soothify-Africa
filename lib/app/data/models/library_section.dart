/// Which library the shelf screen is showing.
///
/// Meditation (Figma 135:11744) and Balance (135:20551) are the same frame
/// with different copy and shelves, so they share one screen rather than two
/// near-identical ones.
enum LibrarySection {
  meditation(
    'meditation',
    'Meditation',
    ['Voice Overs', 'Sleep Stories', 'Sound Effects'],
  ),
  balance(
    'balance',
    'Balance',
    ['Yoga flow', 'Sounds'],
  );

  const LibrarySection(this.id, this.title, this.shelves);

  final String id;
  final String title;

  /// Shelf headings, in the order the design lists them.
  final List<String> shelves;

  /// Both frames use the same placeholder.
  String get searchHint => 'Let’s find your calm';
}
