import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

/// The connecting mark on the joining screens — a pale halo, the brand disc
/// inside it, and a thin arc sweeping round between the two.
///
/// 138 across in `#EDF6FE`, a 92 disc in `#2F6FED` holding the camera glyph,
/// and the arc at radius 55 — in the gap between the two, which is where the
/// frame draws it. The arc is a spinner drawn still, the way
/// a frame has to draw one, so it turns while the call connects.
///
/// Two movements, not one. The arc goes round, and a ring swells out of the
/// disc and fades as it reaches the halo's edge — the radial half, which is
/// what makes this read as *connecting* rather than merely *loading*. Paced
/// at a slow breath, because this is a wellness app and the user is being
/// asked to wait.
///
/// It used to ring both discs in near black at 2.9 and 1.5 — a reading of the
/// frame's outlines that put a heavy donut where the design has a soft halo.
class JoiningPulse extends StatefulWidget {
  const JoiningPulse({super.key});

  @override
  State<JoiningPulse> createState() => _JoiningPulseState();
}

// TickerProviderStateMixin, not the Single one: there are two controllers
// here, and SingleTickerProviderStateMixin asserts the moment a second
// ticker is created.
class _JoiningPulseState extends State<JoiningPulse>
    with TickerProviderStateMixin {
  // `late final`, but initState touches it below — which is what forces the
  // construction to happen there. Left to build alone, a reduce-motion path
  // that never reads it would have dispose construct it, and that throws.
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  /// The outward ripple. Slower than the spin on purpose: two movements at
  /// the same tempo read as one stuttering thing.
  late final AnimationController _swell = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void initState() {
    super.initState();
    _spin.repeat();
    _swell.repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    _swell.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nothing is actually connecting, and a perpetual animation stops any
    // test that waits for a still frame from ever settling.
    final still = MediaQuery.disableAnimationsOf(context);
    if (still) {
      if (_spin.isAnimating) _spin.stop();
      if (_swell.isAnimating) _swell.stop();
    }

    return SizedBox(
      width: 138.h,
      height: 138.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: appTheme.policyPanel,
              shape: BoxShape.circle,
            ),
          ),
          if (!still)
            AnimatedBuilder(
              animation: _swell,
              builder: (context, _) => CustomPaint(
                size: Size.square(138.h),
                painter: _SwellPainter(
                  colour: appTheme.soothifyBlue,
                  t: _swell.value,
                  from: 46.h,
                  to: 69.h,
                ),
              ),
            ),
          AnimatedBuilder(
            animation: _spin,
            builder: (context, _) => CustomPaint(
              size: Size.square(138.h),
              painter: _ArcPainter(
                colour: appTheme.soothifyBlue,
                radius: 55.h,
                width: 3.h,
                // The frame draws it low and to the right; from there it
                // turns, because that is what the mark is for.
                from: -math.pi / 4 + (still ? 0 : _spin.value * 2 * math.pi),
              ),
            ),
          ),
          Container(
            width: 92.h,
            height: 92.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: appTheme.soothifyBlue,
              shape: BoxShape.circle,
            ),
            // The designer's own camera, not the Material stand-in: it is a
            // wider mark with the lens as a separate wedge.
            child: CustomImageView(
              imagePath: ImageConstant.icJoiningCamera,
              width: 43.h,
              height: 29.h,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.colour,
    required this.radius,
    required this.width,
    required this.from,
  });

  final Color colour;
  final double radius;
  final double width;

  /// Where the arc begins, in radians clockwise from three o'clock.
  final double from;

  /// How far it runs — a quarter and a half again, as the frame draws it.
  static const _sweep = math.pi * 0.75;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: radius),
      from,
      _sweep,
      false,
      Paint()
        ..color = colour
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.from != from ||
      old.colour != colour ||
      old.radius != radius ||
      old.width != width;
}

/// A ring leaving the disc and fading into the halo.
///
/// Drawn rather than animated with widgets so the fade and the growth stay in
/// step: an expanding `Container` would have to animate a size and an opacity
/// separately, and they drift.
class _SwellPainter extends CustomPainter {
  const _SwellPainter({
    required this.colour,
    required this.t,
    required this.from,
    required this.to,
  });

  final Color colour;

  /// 0 at the disc's edge, 1 at the halo's.
  final double t;

  final double from;
  final double to;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    // Two rings half a cycle apart, so the gap between them never reads as a
    // stall. Squared falloff: a linear fade still looks bright at the edge.
    for (final phase in const [0.0, 0.5]) {
      final p = (t + phase) % 1;
      final opacity = (1 - p) * (1 - p) * 0.45;
      if (opacity <= 0.01) continue;
      canvas.drawCircle(
        centre,
        from + (to - from) * p,
        Paint()
          ..color = colour.withValues(alpha: opacity)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_SwellPainter old) =>
      old.t != t || old.colour != colour || old.from != from || old.to != to;
}
