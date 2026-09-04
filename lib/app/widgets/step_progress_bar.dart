import 'package:flutter/material.dart';

import '../core/utils/size_utils.dart';
import '../theme/theme_helper.dart';

/// The segmented onboarding progress indicator.
///
/// The design lays out four 77.03 x 3.58 segments across 342 with 10.74
/// between them; expressing it as an even Row of flexible segments keeps the
/// same proportions at any width.
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor,
  });

  final int totalSteps;

  /// 1-based. Segments below this index render filled.
  final int currentStep;

  /// Blue on the light screens, amber on the dark A/B variant.
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? appTheme.soothifyBlue;
    return Row(
      children: List.generate(totalSteps * 2 - 1, (i) {
        if (i.isOdd) return SizedBox(width: 10.74.h);
        final index = i ~/ 2;
        return Expanded(
          child: Container(
            height: 3.58.h,
            decoration: BoxDecoration(
              color: index < currentStep ? active : appTheme.progressTrack,
              borderRadius: BorderRadius.circular(4.h),
            ),
          ),
        );
      }),
    );
  }
}
