import 'package:get/get.dart';

/// A row in Settings, in the order the design lists them.
///
/// [themeToggle] is the odd one out: it carries a switch rather than opening
/// anything, which is why the row type is an enum rather than a bare label.
enum SettingsEntry {
  manageSubscription('settings.manageSubscription', 'ic_settings_subscription'),
  account('settings.account', 'ic_settings_account'),
  // Everything hearted. Sits under Account rather than near the policies:
  // it is the person's own content, not a preference. The glyph is the
  // card's own heart, so the row and the thing it collects match.
  favourites('settings.favourites', 'ic_heart'),
  // The expert's list only. Drawn in the brand blue on its frame — the one
  // row there that is an offer rather than a setting.
  careProtection('settings.careProtection', 'ic_security'),
  themeToggle('settings.themeToggle', 'ic_settings_moon'),
  changeLanguage('settings.changeLanguage', 'ic_settings_language'),
  notifications('settings.notifications', 'ic_settings_notifications'),
  // The designer's screenshot of this screen puts "Become an Expert" here,
  // between Notifications and Privacy Policy. It had been appended near the
  // bottom on the belief that the frame did not draw the row at all.
  //
  // Its glyph used to be the rating star, which is a *filled* 5x5 shape — it
  // read as a solid blob beside nine outlined ones. `ic_settings_expert` is
  // drawn to match the set: a person with a check, 24 square at a 2 stroke.
  becomeExpert('settings.becomeExpert', 'ic_settings_expert'),
  privacyPolicy('settings.privacyPolicy', 'ic_settings_privacy'),
  terms('settings.terms', 'ic_settings_terms'),
  about('settings.about', 'ic_settings_about'),
  logout('settings.logout', 'ic_settings_logout');

  const SettingsEntry(this._label, this._icon);

  final String _label;

  /// Looked up on each read: an enum's values are built once, before any
  /// locale is known, so a label translated in the constructor would stay
  /// in whichever language the app started in.
  String get label => _label.tr;

  final String _icon;

  /// The row's glyph, exported from the Settings frame.
  String get asset => 'assets/icons/$_icon.svg';

  bool get hasToggle => this == SettingsEntry.themeToggle;

  /// What each role sees. The frames draw two different lists: the expert
  /// has no Account row and is not offered "Become an Expert", and carries
  /// the protection hub instead.
  static const forClient = [
    manageSubscription,
    account,
    favourites,
    themeToggle,
    changeLanguage,
    notifications,
    becomeExpert,
    privacyPolicy,
    terms,
    about,
    logout,
  ];

  static const forExpert = [
    manageSubscription,
    careProtection,
    favourites,
    themeToggle,
    changeLanguage,
    notifications,
    privacyPolicy,
    terms,
    about,
    logout,
  ];

  /// The row the frame singles out in blue.
  bool get isHighlighted => this == careProtection;
}
