import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// One entry in the filter menu: what it says, and the sheet it opens.
typedef FilterMenuItem = (String label, String route);

/// The menu that drops out of the filter glyph — Figma
/// "Stretch & Restore/Dropdown" (`259:31342`), drawn identically on the
/// Balance copy (`259:48832`).
///
/// 178x172 at an 8 radius, hung off the glyph's right edge and overlapping
/// the bottom of the search row, with 133x27 pills 8 apart inside 20 of
/// padding. The frames give the glyph no other behaviour, so this is the only
/// way into the filter sheets — they no longer link to each other.
///
/// "Approach" was here and is gone: the design never drew its options, so it
/// opened an empty sheet. "Teacher" has moved out of More filters into its
/// own entry, because it is now the practitioners the server knows rather
/// than a list of seven names the app carried.
const filterMenuItems = <FilterMenuItem>[
  ('Duration', AppRoutes.filterDuration),
  ('Teacher', AppRoutes.filterTeacher),
  ('Style', AppRoutes.filterStyle),
  ('More filters', AppRoutes.filterMore),
];

/// Drops the menu under [anchor] and answers with the route the user picked,
/// or null if they dismissed it.
///
/// [anchor] is the glyph's own build context: its box is what the card is
/// positioned against, so the menu follows the glyph on every screen that
/// carries one rather than being measured per screen.
Future<String?> showFilterMenu(BuildContext anchor) {
  final box = anchor.findRenderObject() as RenderBox?;
  final overlay =
      Navigator.of(anchor).overlay?.context.findRenderObject() as RenderBox?;
  if (box == null || !box.hasSize || overlay == null) {
    return Future<String?>.value(null);
  }

  final corner = box.localToGlobal(Offset.zero, ancestor: overlay);
  // 3 under the glyph, right edges flush — both measured off the frame,
  // where the card's right edge and the glyph's land on the same x.
  final top = corner.dy + box.size.height + 3.v;
  final right = overlay.size.width - (corner.dx + box.size.width);

  return showGeneralDialog<String>(
    context: anchor,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(anchor).modalBarrierDismissLabel,
    // No scrim: the frame shows the library at full strength behind the card.
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 120),
    pageBuilder: (context, _, _) => Stack(
      children: [
        Positioned(top: top, right: right, child: const _FilterMenu()),
      ],
    ),
    transitionBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

class _FilterMenu extends StatelessWidget {
  const _FilterMenu();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 178.h,
        padding: EdgeInsets.symmetric(horizontal: 22.h, vertical: 20.v),
        decoration: BoxDecoration(
          color: appTheme.filterChipFill,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(color: appTheme.menuRim),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, (label, route)) in filterMenuItems.indexed) ...[
              if (i > 0) SizedBox(height: 8.v),
              _MenuPill(
                label: label,
                onTap: () => Navigator.of(context).pop(route),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuPill extends StatelessWidget {
  const _MenuPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.h),
      child: Container(
        height: 27.v,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: appTheme.filterChipFill,
          borderRadius: BorderRadius.circular(20.h),
          border: Border.all(color: appTheme.cardHairline),
        ),
        child: Text(label, style: CustomTextStyles.filterMenuItem),
      ),
    );
  }
}
