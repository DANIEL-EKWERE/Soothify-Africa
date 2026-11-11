import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controller/breathe_controller.dart';

/// Teal wave lines that breathe the cycle during the minute.
///
/// They replace the swelling circle while the exercise runs; the circle is
/// still what greets you before it and what you finish on. Like the circle,
/// they are the thing you breathe along with, so they move with the cue and
/// not merely near it: the waves rise over the four seconds of the inhale,
/// hold for the two of the hold, and settle over the six of the exhale.
/// Under that they drift slowly sideways the whole time, so the screen is
/// never still even during a hold.
///
/// One repeating 12-second pass drives both the rise and the drift, and the
/// drift completes a whole number of turns per pass -- so the loop has no
/// seam, and the waves and the words under the clock always agree.
class BreathWaves extends StatefulWidget {
  const BreathWaves({super.key, required this.height});

  final double height;

  @override
  State<BreathWaves> createState() => _BreathWavesState();
}

class _BreathWavesState extends State<BreathWaves>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cycle = AnimationController(
    vsync: this,
    duration: Duration(seconds: BreatheCue.cycleSeconds),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // From 0 -- the start of an inhale -- so the first thing you see is the
    // waves beginning to rise under "Breathe in". Held still where motion
    // is turned off.
    if (MediaQuery.disableAnimationsOf(context)) {
      _cycle.stop();
    } else if (!_cycle.isAnimating) {
      _cycle.repeat();
    }
  }

  @override
  void dispose() {
    _cycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final still = MediaQuery.disableAnimationsOf(context);
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _cycle,
        builder: (context, _) {
          final seconds = _cycle.value * BreatheCue.cycleSeconds;
          return CustomPaint(
            painter: BreathWavePainter(
              drift: still ? 0 : _cycle.value,
              // Mid-breath where motion is off: a wave, not a flat line.
              fullness: still ? 0.5 : BreatheCue.fullnessAt(seconds),
              teal: dark ? BreathWavePainter.darkTeal : BreathWavePainter.lightTeal,
            ),
          );
        },
      ),
    );
  }
}

/// Three lines, the brightest in front, drawn as sums of sines.
///
/// Public so a test can read [fullness] off the screen the way it once
/// measured the circle's width.
class BreathWavePainter extends CustomPainter {
  BreathWavePainter({
    required this.drift,
    required this.fullness,
    required this.teal,
  });

  /// How far through the 12-second pass, 0 to 1. Each line turns a whole
  /// number of times per pass, so 0 and 1 draw the same picture.
  final double drift;

  /// 0 at rest, 1 at the top of a breath.
  final double fullness;

  final Color teal;

  /// Deep enough to hold its own on the light background.
  static const lightTeal = Color(0xFF14A3AE);

  /// Brighter, as in the reference, on the dark one.
  static const darkTeal = Color(0xFF3CD3DC);

  /// The wave's height either side of the middle, as a share of the box:
  /// a low swell at rest, most of the box at the top of a breath.
  static const double restAmplitude = 0.07;
  static const double fullAmplitude = 0.36;

  double amplitudeFor(Size size) =>
      size.height * (restAmplitude + (fullAmplitude - restAmplitude) * fullness);

  static const _lines = [
    // phase, spatial frequency, share of amplitude, turns per pass, width, opacity
    (0.0, 1.00, 1.00, 1, 2.4, 1.00),
    (0.9, 1.18, 0.82, 2, 1.6, 0.55),
    (-1.2, 0.86, 0.66, -1, 1.3, 0.32),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    final amplitude = amplitudeFor(size);

    // Back to front, so the brightest line sits on top.
    for (final (phase, frequency, share, turns, width, opacity)
        in _lines.reversed) {
      final path = Path();
      for (var x = 0.0; x <= size.width + 2; x += 3) {
        final theta = 2 * math.pi * (x / size.width) * frequency * 0.9 +
            phase +
            2 * math.pi * turns * drift;
        // A second, smaller harmonic keeps it from reading as a textbook
        // sine -- the reference's lines are slightly uneven.
        final wave = 0.82 * math.sin(theta) + 0.18 * math.sin(2 * theta + 1.3);
        final y = mid + amplitude * share * wave;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      if (opacity == 1.0) {
        // A soft glow under the front line, as in the reference.
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = width * 3.2
            ..strokeCap = StrokeCap.round
            ..color = teal.withValues(alpha: 0.16)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = true
          ..color = teal.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(BreathWavePainter old) =>
      old.drift != drift || old.fullness != fullness || old.teal != teal;
}
