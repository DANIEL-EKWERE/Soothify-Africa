import 'package:flutter/material.dart';

/// A row in Settings, in the order the design lists them.
///
/// [themeToggle] is the odd one out: it carries a switch rather than opening
/// anything, which is why the row type is an enum rather than a bare label.
enum SettingsEntry {
  manageSubscription('Manage subscription', Icons.card_membership_outlined),
  account('Account', Icons.person_outline),
  themeToggle('Light Mode', Icons.dark_mode_outlined),
  changeLanguage('Change Language', Icons.language_outlined),
  notifications('Notifications', Icons.notifications_none),
  privacyPolicy('Privacy Policy', Icons.lock_outline),
  terms('Terms & Conditions', Icons.description_outlined),
  about('About Us', Icons.info_outline),
  logout('Logout', Icons.logout);

  const SettingsEntry(this.label, this.icon);

  final String label;

  /// Material stands in until the design's own icon set is exported.
  final IconData icon;

  bool get hasToggle => this == SettingsEntry.themeToggle;
}
