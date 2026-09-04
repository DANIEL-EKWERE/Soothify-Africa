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
  logout('Logout', 'ic_settings_logout');

  const SettingsEntry(this.label, this._icon);

  final String label;

  final String _icon;

  /// The row's glyph, exported from the Settings frame.
  String get asset => 'assets/icons/$_icon.svg';

  bool get hasToggle => this == SettingsEntry.themeToggle;
}
