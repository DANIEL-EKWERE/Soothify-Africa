import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'nav_destination.dart';

/// The five destinations in the signed-in bottom navigation, in the order the
/// design lays them out.
enum AppTab implements NavDestination {
  home('nav.home', 'nav_home'),
  plans('nav.plans', 'nav_plans'),
  discovery('nav.discovery', 'nav_discovery'),
  community('nav.community', 'nav_community'),
  profile('nav.profile', 'nav_profile');

  const AppTab(this._key, this._icon);

  /// Looked up rather than held: the bar is redrawn when the language
  /// changes, and a const label would keep saying what it said at startup.
  final String _key;

  @override
  String get label => _key.tr;

  final String _icon;

  /// The glyph exported from the nav component. One per tab, not two: the
  /// design marks the active tab with a gradient fill, never a filled variant.
  @override
  String get asset => 'assets/icons/$_icon.svg';

  /// Every one of these was exported, so none needs a Material stand-in.
  @override
  IconData? get icon => null;
}
