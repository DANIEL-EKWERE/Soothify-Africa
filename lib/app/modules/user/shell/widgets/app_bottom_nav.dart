import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/nav_destination.dart';

/// The signed-in bottom navigation — 74 tall, five evenly spaced tabs with a
/// label beneath each icon.
///
/// Hand-built rather than a Material [BottomNavigationBar], which imposes its
/// own height and padding and cannot be held to the design's 74.
///
/// Measured from the nav component (`Frame 1618868549`, 390x74.4, white):
/// labels are Nunito Sans 400 at 10.88 with a 14.8 line height, the active one
/// gradient-filled `#4B84F6 -> #0A399A`, the rest flat `#999999`.
///
/// Icons are the design's own, exported from the nav component as SVG. The
/// expert bar's three middle glyphs were not exportable, so a destination may
/// carry a Material [IconData] instead — see [NavDestination].
///
/// Shared by both roles: the client bar (`AppTab`) and the expert one
/// (`ExpertTab`) are the same 74-tall five-up bar.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<NavDestination> tabs;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  /// The bar's own height, before the system inset beneath it.
  static const double barHeight = 74;

  /// How tall the bar actually is on this device: its 74 plus whatever the
  /// system navigation takes at the bottom.
  static double heightFor(BuildContext context) =>
      barHeight.h + MediaQuery.viewPaddingOf(context).bottom;

  @override
  Widget build(BuildContext context) {
    // The inset pads *under* a full-height bar rather than being taken out of
    // it. A SafeArea inside the 74 box subtracted the system navigation's
    // height from the tabs instead, so on a phone with on-screen nav buttons
    // the bar was squashed and sat behind them.
    return Container(
      color: appTheme.surface,
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: SizedBox(
        height: barHeight.h,
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: _NavItem(
                  tab: tabs[i],
                  isSelected: i == currentIndex,
                  onTap: () => onSelected(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final NavDestination tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // White under the shader when selected; srcIn takes the gradient
        // from whatever is opaque, so the base colour must not be faded.
        if (tab.asset case final path?)
          CustomImageView(
            imagePath: path,
            height: 24.h,
            width: 24.h,
            color: isSelected ? appTheme.onPrimary : appTheme.navInactive,
          )
        else
          Icon(
            tab.icon,
            size: 24.h,
            color: isSelected ? appTheme.onPrimary : appTheme.navInactive,
          ),
        SizedBox(height: 3.h),
        Text(
          tab.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CustomTextStyles.navLabel.copyWith(
            color: isSelected ? appTheme.onPrimary : appTheme.navInactive,
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      selected: isSelected,
      label: tab.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        // The active tab is gradient-filled. Its own pair, not the one the
        // titles use. Masking icon and label together keeps a single
        // continuous fill down the item.
        child: isSelected
            ? ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => appTheme.navActiveGradient
                    .createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: content,
              )
            : content,
      ),
    );
  }
}
