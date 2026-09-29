import 'dart:math';

import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// A one-shot confetti burst for the match celebration — Figma
/// "Matched with instructor celebration (signed user)" (`259:31992`).
///
/// That frame and the plain "Matched with instructor" frame (`259:31617`)
/// carry identical copy; the celebration is the whole difference between
/// them, which is why it lives here as an overlay rather than as a variant of
/// the view underneath.
///
/// Painted rather than packaged: a dependency for forty falling rectangles
/// would be the largest thing in `pubspec.yaml` after `get`, and a painter
/// lets the burst be seeded so the goldens are stable.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({
    super.key,
    this.pieces = 40,
    this.duration = const Duration(milliseconds: 2600),
    this.onFinished,
  });

  /// How many pieces fall. Forty reads as a celebration at 390 wide without
  /// obscuring the coach's photograph behind it.
  final int pieces;

  final Duration duration;

  /// Called once the burst has settled, so the caller can retire it. A back
  /// press returning to this screen should find the plain frame, not a second
  /// celebration.
  final VoidCallback? onFinished;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  /// Built in [initState], not lazily. Under reduce motion the build never
  /// touches this field, so a `late` initialiser would run for the first time
  /// inside [dispose] — and constructing a ticker while the element is being
  /// unmounted throws "looking up a deactivated widget's ancestor". The same
  /// trap bit the KYC intro's tap hint before it was removed.
  late final AnimationController _fall;

  /// Fixed seed: the burst looks scattered but falls the same way every run,
  /// so a golden of this screen is reproducible.
  late final List<_Piece> _confetti;

  bool _started = false;

  @override
  void initState() {
    super.initState();
    _fall = AnimationController(vsync: this, duration: widget.duration);
    _confetti = _Piece.scatter(widget.pieces, Random(7));
  }

  @override
  void dispose() {
    _fall.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reduce motion means no burst at all. A celebration is decoration — it
    // carries nothing the copy underneath does not already say, so the honest
    // response to "no animations" is to skip it rather than to show a frozen
    // scatter of paper over the screen.
    if (MediaQuery.disableAnimationsOf(context)) {
      if (!_started) {
        _started = true;
        WidgetsBinding.instance
            .addPostFrameCallback((_) => widget.onFinished?.call());
      }
      return const SizedBox.shrink();
    }

    if (!_started) {
      _started = true;
      _fall.forward().whenComplete(() {
        if (mounted) widget.onFinished?.call();
      });
    }

    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _fall,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(
              pieces: _confetti,
              progress: _fall.value,
              colors: [
                appTheme.soothifyBlue,
                appTheme.accent,
                appTheme.success,
                // The darker end of the header's own gradient, so the burst
                // belongs to this app rather than to a stock palette.
                const Color(0xFF274889),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One piece of paper, described in fractions of the painted area so the
/// burst fits whatever box it is given.
class _Piece {
  const _Piece({
    required this.x,
    required this.delay,
    required this.drift,
    required this.size,
    required this.spin,
    required this.colorIndex,
    required this.round,
  });

  /// Horizontal start, 0..1 of the width.
  final double x;

  /// How far into the burst this piece starts falling, 0..0.4. Staggering the
  /// start is what makes it read as thrown rather than dropped.
  final double delay;

  /// Sideways travel over the fall, in fractions of the width.
  final double drift;

  final double size;

  /// Turns over the whole fall.
  final double spin;

  final int colorIndex;

  /// Rounds a quarter of them, so the burst is not uniformly rectangular.
  final bool round;

  static List<_Piece> scatter(int count, Random random) => [
        for (var i = 0; i < count; i++)
          _Piece(
            x: random.nextDouble(),
            delay: random.nextDouble() * 0.4,
            drift: (random.nextDouble() - 0.5) * 0.3,
            size: 6 + random.nextDouble() * 6,
            spin: 1 + random.nextDouble() * 3,
            colorIndex: random.nextInt(4),
            round: random.nextInt(4) == 0,
          ),
      ];
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({
    required this.pieces,
    required this.progress,
    required this.colors,
  });

  final List<_Piece> pieces;
  final double progress;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final piece in pieces) {
      // Each piece runs its own 0..1 within the remaining time after its
      // delay, so the last ones still land before the burst ends.
      final span = 1 - piece.delay;
      final t = ((progress - piece.delay) / span).clamp(0.0, 1.0);
      if (t <= 0) continue;

      // Falls from just above the top to just past the bottom, fading out
      // over the last third rather than vanishing mid-air.
      final dy = (-0.1 + t * 1.2) * size.height;
      final dx = (piece.x + piece.drift * t) * size.width;
      final opacity = t < 0.66 ? 1.0 : (1 - t) / 0.34;

      paint.color = colors[piece.colorIndex].withValues(alpha: opacity);

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(piece.spin * t * 2 * pi);
      final half = piece.size / 2;
      if (piece.round) {
        canvas.drawCircle(Offset.zero, half, paint);
      } else {
        // Paper, not squares: half as tall as it is wide.
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: half,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.progress != progress || old.colors != colors;
}
