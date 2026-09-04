import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/kyc_question.dart';

/// One answer row: 342x48, 4px radius, optional 30px icon 13 from the left
/// with the label 8 beyond it. Selection swaps the 4%-ink hairline for the
/// brand blue, exactly as the design does.
class KycOptionTile extends StatelessWidget {
  const KycOptionTile({
    super.key,
    required this.option,
    required this.isSelected,
    this.onTap,
  });

  final KycOption option;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: option.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 13.h),
          decoration: BoxDecoration(
            color: appTheme.surface,
            borderRadius: BorderRadius.circular(4.h),
            border: Border.all(
              color: isSelected ? appTheme.soothifyBlue : appTheme.optionBorder,
            ),
          ),
          child: Row(
            children: [
              if (option.assetPath != null) ...[
                Image.asset(
                  option.assetPath!,
                  height: 30.h,
                  width: 30.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 8.h),
              ],
              Expanded(
                child: Text(
                  option.label,
                  style: CustomTextStyles.optionLabel,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
