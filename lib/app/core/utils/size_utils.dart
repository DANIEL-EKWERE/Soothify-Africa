import 'package:flutter/material.dart';

// Reference design frame, taken from the Figma artboards (390x844, iPhone
// 14/15). Every `.h` / `.v` value in the app scales against this.
const num figmaDesignWidth = 390;
const num figmaDesignHeight = 844;
const num figmaDesignStatusBar = 0;

/// Wraps a screen so responsive extensions have a [BoxConstraints] to read.
class Sizer extends StatelessWidget {
  const Sizer({super.key, required this.builder});

  final Widget Function(BuildContext, BoxConstraints, Orientation) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            SizeUtils.setScreenSize(constraints, orientation);
            return builder(context, constraints, orientation);
          },
        );
      },
    );
  }
}

class SizeUtils {
  // Seeded with the design frame rather than declared `late`, so a widget
  // built outside a [Sizer] — in a test, a dialog, or by mistake — degrades
  // to 1:1 design units instead of throwing LateInitializationError.
  static BoxConstraints boxConstraints = const BoxConstraints();
  static Orientation orientation = Orientation.portrait;
  static DeviceType deviceType = DeviceType.mobile;
  static double height = figmaDesignHeight.toDouble();
  static double width = figmaDesignWidth.toDouble();

  static void setScreenSize(
    BoxConstraints constraints,
    Orientation currentOrientation,
  ) {
    boxConstraints = constraints;
    orientation = currentOrientation;
    if (orientation == Orientation.portrait) {
      width = constraints.maxWidth.isNonZero(defaultValue: figmaDesignWidth);
      height = constraints.maxHeight.isNonZero(defaultValue: figmaDesignHeight);
    } else {
      width = constraints.maxHeight.isNonZero(defaultValue: figmaDesignWidth);
      height = constraints.maxWidth.isNonZero(defaultValue: figmaDesignHeight);
    }
    deviceType = DeviceType.mobile;
  }
}

enum DeviceType { mobile, tablet, desktop }

extension ResponsiveExtension on num {
  double get _width => SizeUtils.width;

  /// Horizontal / general scaling against the design width.
  double get h => ((this * _width) / figmaDesignWidth);

  /// Vertical scaling. Kept proportional to width so aspect ratios hold.
  double get v =>
      (this * (SizeUtils.height - figmaDesignStatusBar)) /
      (figmaDesignHeight - figmaDesignStatusBar);

  /// Font sizing — uses the smaller axis so text never overflows.
  double get fSize => h < v ? h : v;

  double get adaptSize => fSize;
}

extension FormatExtension on double {
  double toDoubleValue({int fractionDigits = 2}) =>
      double.parse(toStringAsFixed(fractionDigits));

  double isNonZero({num defaultValue = 0.0}) =>
      this > 0 ? this : defaultValue.toDouble();
}
