/// A topic chip on the Community screen.
///
/// The design lists "Sad" twice (Figma 135:5006 and 135:5018) — almost
/// certainly a slip in the file rather than two distinct topics. Both are
/// reproduced so the grid matches the frame, with distinct ids so selection
/// still behaves; worth confirming with the designer before launch.
enum CommunityTopic {
  happy('happy', 'Happy'),
  sad('sad', 'Sad'),
  depression('depression', 'Depression'),
  anxiety('anxiety', 'Anxiety'),
  panic('panic', 'Panic'),
  sadDuplicate('sad-2', 'Sad'),
  others('others', 'Others');

  const CommunityTopic(this.id, this.label);

  final String id;
  final String label;

  /// The last chip carries an ellipsis glyph rather than artwork.
  bool get isOthers => this == CommunityTopic.others;
}
