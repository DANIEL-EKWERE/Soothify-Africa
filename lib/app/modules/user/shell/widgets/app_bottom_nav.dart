import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/app_tab.dart';

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
/// Icons are the design's own, exported from the nav component as SVG.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<AppTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74.h,
      decoration: BoxDecoration(color: appTheme.surface),
      child: SafeArea(
        top: false,
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

  final AppTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomImageView(
          imagePath: tab.asset,
          height: 24.h,
          width: 24.h,
          // White under the shader when selected; srcIn takes the gradient
          // from whatever is opaque, so the base colour must not be faded.
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
