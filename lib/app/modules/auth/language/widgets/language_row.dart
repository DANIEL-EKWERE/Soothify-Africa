import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/app_language.dart';

/// One language option: 342x48, 4px radius, centred label. Selection swaps the
/// hairline for the brand blue, exactly as the design does.
class LanguageRow extends StatelessWidget {
  const LanguageRow({
    super.key,
    required this.language,
    required this.isSelected,
    this.onTap,
  });

  final AppLanguage language;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: language.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 48.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: appTheme.surface,
            borderRadius: BorderRadius.circular(4.h),
            border: Border.all(
              color: isSelected ? appTheme.soothifyBlue : appTheme.rowBorder,
              // The design draws the unselected hairline at 0.2; that rounds
              // away on most densities, so it sits at the thinnest visible.
              width: isSelected ? 1 : 0.5,
            ),
          ),
          child: Text(language.label, style: CustomTextStyles.languageOption),
        ),
      ),
    );
  }
}
