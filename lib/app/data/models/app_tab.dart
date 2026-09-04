import 'package:flutter/material.dart';

/// The five destinations in the signed-in bottom navigation, in the order the
/// design lays them out.
///
/// Each has its own section in the Figma file, so only [home] is being built
/// now; the rest are registered so the shell is complete and each screen can
/// drop in without touching navigation.
enum AppTab {
  home('Home', Icons.home_outlined, Icons.home),
  plans('Plans', Icons.star_outline, Icons.star),
  discovery('Discovery', Icons.search_outlined, Icons.search),
  community('Community', Icons.people_outline, Icons.people),
  profile('Profile', Icons.sentiment_satisfied_outlined, Icons.sentiment_satisfied);

  const AppTab(this.label, this.icon, this.activeIcon);

  final String label;

  /// Material icons stand in until the design's own icon set is exported.
  final IconData icon;
  final IconData activeIcon;
}
