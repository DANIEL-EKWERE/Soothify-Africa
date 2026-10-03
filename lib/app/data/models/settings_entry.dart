/// A row in Settings, in the order the design lists them.
///
/// [themeToggle] is the odd one out: it carries a switch rather than opening
/// anything, which is why the row type is an enum rather than a bare label.
enum SettingsEntry {
  manageSubscription('Manage subscription', 'ic_settings_subscription'),
  account('Account', 'ic_settings_account'),
  themeToggle('Light Mode', 'ic_settings_moon'),
  changeLanguage('Change Language', 'ic_settings_language'),
  notifications('Notifications', 'ic_settings_notifications'),
  // The designer's screenshot of this screen puts "Become an Expert" here,
  // between Notifications and Privacy Policy. It had been appended near the
  // bottom on the belief that the frame did not draw the row at all.
  //
  // Its glyph used to be the rating star, which is a *filled* 5x5 shape — it
  // read as a solid blob beside nine outlined ones. `ic_settings_expert` is
  // drawn to match the set: a person with a check, 24 square at a 2 stroke.
  becomeExpert('Become an Expert', 'ic_settings_expert'),
  privacyPolicy('Privacy Policy', 'ic_settings_privacy'),
  terms('Terms & Conditions', 'ic_settings_terms'),
  about('About Us', 'ic_settings_about'),
  logout('Logout', 'ic_settings_logout');

  const SettingsEntry(this.label, this._icon);

  final String label;

  final String _icon;

  /// The row's glyph, exported from the Settings frame.
  String get asset => 'assets/icons/$_icon.svg';

  bool get hasToggle => this == SettingsEntry.themeToggle;
}
