/// The five destinations in the signed-in bottom navigation, in the order the
/// design lays them out.
enum AppTab {
  home('Home', 'nav_home'),
  plans('Plans', 'nav_plans'),
  discovery('Discovery', 'nav_discovery'),
  community('Community', 'nav_community'),
  profile('Profile', 'nav_profile');

  const AppTab(this.label, this._icon);

  final String label;

  final String _icon;

  /// The glyph exported from the nav component. One per tab, not two: the
  /// design marks the active tab with a gradient fill, never a filled variant.
  String get asset => 'assets/icons/$_icon.svg';
}
