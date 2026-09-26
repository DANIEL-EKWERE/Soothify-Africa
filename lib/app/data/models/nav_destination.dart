import 'package:flutter/widgets.dart';

/// One destination in a bottom navigation bar.
///
/// Both roles have a five-tab bar of the same shape, so they share
/// `AppBottomNav`. This is what the bar needs from either: a label and a
/// glyph. Implemented by [AppTab] and [ExpertTab].
abstract interface class NavDestination {
  String get label;

  /// The design's own SVG, when it was exported. Null when [icon] stands in.
  String? get asset;

  /// A Material glyph, for a tab whose designed icon could not be exported.
  /// Exactly one of [asset] and [icon] is non-null.
  IconData? get icon;
}
