import 'package:flutter/material.dart';

import 'nav_destination.dart';

/// The expert role's bottom navigation — Figma "Expert dashboard"
/// (`259:59239`) and every other frame in that row.
///
/// The designer built this bar by reusing the client one: its text layers are
/// still named "Plans" and "Discovery" while reading "Schedule" and
/// "Earnings". The *icons* are new though — `akar-icons:calendar`,
/// `ion:wallet-outline` and `ci:note-edit` — so this is a real second bar, not
/// the client's with different words.
enum ExpertTab implements NavDestination {
  home('Home', asset: 'nav_home'),
  schedule('Schedule', icon: Icons.calendar_today_outlined),
  earnings('Earnings', icon: Icons.account_balance_wallet_outlined),
  notes('Notes', icon: Icons.edit_note_outlined),
  profile('Profile', asset: 'nav_profile');

  const ExpertTab(this.label, {String? asset, this.icon})
      : _asset = asset,
        assert((asset == null) != (icon == null), 'exactly one glyph source');

  @override
  final String label;

  final String? _asset;

  /// Home and Profile draw the same `home-smile` and `face-smile` the client
  /// bar does, so they use the app's own exports.
  @override
  String? get asset => _asset == null ? null : 'assets/icons/$_asset.svg';

  /// The three middle glyphs are the expert bar's own and were not
  /// exportable — the images endpoint was out of quota — so Material's
  /// outlines stand in. Swap for the real SVGs when they can be pulled.
  @override
  final IconData? icon;
}
