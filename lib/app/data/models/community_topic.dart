/// A topic chip on the Community screen.
///
/// The design lists "Sad" twice (Figma 135:5006 and 135:5018) — almost
/// certainly a slip in the file rather than two distinct topics. Both are
/// reproduced so the grid matches the frame, with distinct ids so selection
/// still behaves; worth confirming with the designer before launch.
enum CommunityTopic {
  happy('happy', 'Happy', 'happy'),
  sad('sad', 'Sad', 'sad'),
  depression('depression', 'Depression', 'depress'),
  anxiety('anxiety', 'Anxiety', 'anxious'),
  // No "panic" face exists in the emoji set; fearful is the nearest of the
  // nine. Swap it if the designer exports a dedicated one.
  panic('panic', 'Panic', 'fearful'),
  sadDuplicate('sad-2', 'Sad', 'sad'),
  others('others', 'Others', null);

  const CommunityTopic(this.id, this.label, this._emoji);

  final String id;
  final String label;

  final String? _emoji;

  /// The chip's face, from the app's own emoji set.
  ///
  /// The Community frame points five of its six chips at the *same* image
  /// (`image 1925`), so the file has not settled on per-topic art. These map
  /// each topic to the matching face from the mood set, which is the same
  /// family drawn for the mood checker.
  String? get assetPath =>
      _emoji == null ? null : 'assets/images/moods/$_emoji.png';

  /// The last chip carries an ellipsis glyph rather than a face.
  bool get isOthers => this == CommunityTopic.others;
}
