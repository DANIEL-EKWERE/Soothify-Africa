import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'nav_destination.dart';

/// The expert role's bottom navigation — Figma "Expert dashboard"
/// (`3792:29745`) and every other frame in that row.
///
/// Four tabs, not five. A fifth "Profile" was built from a copy of the
/// design file; the live one draws Home / Schedule / Earnings / Notes on the
/// dashboard, the earnings screen and the payouts screens alike. The
/// expert's profile is reached from the avatar in the dashboard header
/// instead — see `AppRoutes.expertProfile`.
///
/// The designer built this bar by reusing the client one: its text layers are
/// still named "Plans" and "Discovery" while reading "Schedule" and
/// "Earnings". The *icons* are new though — `akar-icons:calendar`,
/// `ion:wallet-outline` and `ci:note-edit` — so this is a real second bar, not
/// the client's with different words.
enum ExpertTab implements NavDestination {
  home('nav.home', asset: 'nav_home'),
  schedule('nav.schedule', asset: 'ic_calendar_outline'),
  earnings('nav.earnings', asset: 'ic_wallet'),
  notes('nav.notes', asset: 'ic_note_edit');

  const ExpertTab(this._key, {String? asset, this.icon})
      : _asset = asset,
        assert((asset == null) != (icon == null), 'exactly one glyph source');

  /// Looked up, not held — see AppTab.
  final String _key;

  @override
  String get label => _key.tr;

  final String? _asset;

  /// Every tab now draws a real glyph: `home-smile` is the client bar's own
  /// export, and `akar-icons:calendar`, `ion:wallet-outline` and
  /// `ci:note-edit` are the expert bar's. The middle three stood in as
  /// Material icons for a while because the images endpoint was out of
  /// quota and the wallet had never been exported at all.
  @override
  String? get asset => _asset == null ? null : 'assets/icons/$_asset.svg';

  /// Kept on the interface, and now unused: every tab has its own SVG.
  @override
  final IconData? icon;
}
