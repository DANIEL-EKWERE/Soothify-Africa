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
  privacyPolicy('Privacy Policy', 'ic_settings_privacy'),
  terms('Terms & Conditions', 'ic_settings_terms'),
  about('About Us', 'ic_settings_about'),
  // Not a row the Settings frame draws. The "Become an Expert" flow
  // (`259:59132` onward) has no entry point anywhere in the file, and this is
  // the app's list of account-level actions, so it goes here. The glyph is
  // borrowed from the rating star; there is no exported one for it, and the
  // live-session camcorder read as "video" rather than "expert".
  becomeExpert('Become an Expert', 'ic_star'),
  logout('Logout', 'ic_settings_logout');

  const SettingsEntry(this.label, this._icon);

  final String label;

  final String _icon;

  /// The row's glyph, exported from the Settings frame.
  String get asset => 'assets/icons/$_icon.svg';

  bool get hasToggle => this == SettingsEntry.themeToggle;
}
