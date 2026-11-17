import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import 'nav_destination.dart';

/// The studio partner's bottom navigation — the "Partner navigation" frame
/// (`416:26366`), 82 tall, drawn at the foot of every partner screen.
///
/// Three tabs, not four. The portal frames draw a fourth "Notes" beside
/// these, but they are a copy of the expert bar — same four labels, same
/// three glyphs — and they are the only two frames that show it: the ledger,
/// the schedule, the roster, both check-in results and the dispute all draw
/// Home / Schedule / Earnings alone. There is no partner notes screen in the
/// design or the app, so a fourth tab would lead nowhere.
///
/// The glyphs are the expert bar's own exports, which is what the frames
/// use: `home-smile`, `akar-icons:calendar` and `ion:wallet-outline`.
enum PartnerNavTab implements NavDestination {
  /// The portal and its two tabs — Overview and Active Guest List.
  home('nav.home', asset: 'nav_home', route: AppRoutes.partnerPortal),

  /// The slot manager, and the roster and check-in screens beneath it.
  schedule(
    'nav.schedule',
    asset: 'ic_calendar_outline',
    route: AppRoutes.partnerSchedule,
  ),

  /// The payout ledger.
  earnings('nav.earnings', asset: 'ic_wallet', route: AppRoutes.partnerLedger);

  const PartnerNavTab(this._key, {required String asset, required this.route})
      : _asset = asset;

  /// Looked up on each read, not stored: an enum's values are built once,
  /// before a locale is known — see [AppTab].
  final String _key;

  @override
  String get label => _key.tr;

  final String _asset;

  @override
  String get asset => 'assets/icons/$_asset.svg';

  /// Every partner tab has a real glyph, so this is always null.
  @override
  IconData? get icon => null;

  /// Where the tab goes. The screens beneath a tab — the roster under
  /// Schedule, for instance — keep that tab lit rather than lighting none.
  final String route;
}
