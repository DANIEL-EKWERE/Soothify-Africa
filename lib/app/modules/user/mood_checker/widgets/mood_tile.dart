import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/mood.dart';

/// One mood in the grid: a 100x100 white card holding a 43x43 emoji, with the
/// label 8px beneath it. Measurements come straight from the Figma frame.
class MoodTile extends StatelessWidget {
  const MoodTile({
    super.key,
    required this.mood,
    required this.isSelected,
    this.onTap,
  });

  final Mood mood;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: mood.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 100.h,
              width: double.infinity,
              padding: EdgeInsets.all(10.h),
              alignment: Alignment.center,
              decoration:
                  isSelected ? AppDecoration.cardSelected : AppDecoration.card,
              child: Image.asset(
                mood.assetPath,
                height: 43.h,
                width: 43.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              mood.label,
              textAlign: TextAlign.center,
              style: CustomTextStyles.tileCaption,
            ),
          ],
        ),
      ),
    );
  }
}
