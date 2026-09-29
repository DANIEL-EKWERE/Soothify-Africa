import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// The wide, flat progress bar the booking flow uses — Figma
/// `Pilates kyc` (259:38525), `Scheduling Kyc/Yoga` (259:38802) and
/// `Matching pilates instructor` (259:58806), which all draw the same one.
///
/// 280.7x7 in `#DADADA` with an 18.33 radius, filled `#2F6FED`. Shared
/// because three screens draw it and it is the thing that tells the user the
/// screen is working rather than stuck.
///
/// The frames all park the fill at 128 of 280.7 — a still frame's way of
/// drawing motion, not a measurement, so the caller supplies the value.
class MatchProgressBar extends StatelessWidget {
  const MatchProgressBar({super.key, required this.value, this.fillOpacity = 1});

  final double value;

  /// The matching screen draws its fill at 70%; the KYC intros draw it solid.
  final double fillOpacity;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 280.7.h,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.3.h),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 7.v,
            backgroundColor: appTheme.progressTrack,
            valueColor: AlwaysStoppedAnimation(
              appTheme.soothifyBlue.withValues(alpha: fillOpacity),
            ),
          ),
        ),
      ),
    );
  }
}
