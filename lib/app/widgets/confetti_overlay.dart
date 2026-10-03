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
/// Painted rather than packaged: a dependency for a hundred rectangles would
/// be the largest thing in `pubspec.yaml` after `get`, and a painter lets the
/// burst be seeded so the goldens are stable.
///
/// Two cannons at the bottom corners fire up and inward; each piece is a
/// projectile under gravity and linear drag, tumbling about its own long axis
/// as it goes. It used to be a row of pieces across the top falling straight
/// down on a sine rail, which read as rain rather than as a pop.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({
    super.key,
    this.pieces = 120,
    this.duration = const Duration(milliseconds: 2800),
    this.onFinished,
  });

  /// How many pieces the two cannons throw between them.
  ///
  /// Forty was too thin to read as a celebration. A hundred and twenty fills
  /// the arc without hiding the coach's photograph behind it.
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
              seconds: widget.duration.inMilliseconds / 1000,
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

/// One piece of paper, launched from a cannon and then left to physics.
///
/// Everything is in fractions of the painted area per second, so the burst
/// behaves the same whatever box it is given.
class _Piece {
  const _Piece({
    required this.x0,
    required this.y0,
    required this.vx,
    required this.vy,
    required this.delay,
    required this.size,
    required this.aspect,
    required this.spin,
    required this.flipRate,
    required this.flipPhase,
    required this.colorIndex,
  });

  /// Where it leaves the cannon.
  final double x0;
  final double y0;

  /// Launch velocity, in fractions of the box per second. [vy] is negative
  /// going up.
  final double vx;
  final double vy;

  /// Cannons do not fire every piece on the same frame; 0..0.12s of scatter
  /// is enough to stop the burst reading as one rigid sheet.
  final double delay;

  /// The long edge, in logical pixels.
  final double size;

  /// Short edge over long edge. Around 0.6 for paper, 0.2 for a streamer.
  final double aspect;

  /// Turns per second in the plane of the screen.
  final double spin;

  /// Turns per second about the piece's own long axis. This is the one that
  /// sells it: a flat rectangle tumbling in three dimensions goes edge-on
  /// twice a turn, and that flicker is what paper does and a sprite does not.
  final double flipRate;

  final double flipPhase;

  final int colorIndex;

  /// Two cannons at the bottom corners, firing up and inward.
  ///
  /// This replaced a scatter across the top that fell straight down on a sine
  /// rail. Nothing about that read as a pop: real confetti leaves fast, slows
  /// against the air, turns over at the top of its arc and comes down a good
  /// deal slower than it went up.
  static List<_Piece> scatter(int count, Random random) {
    final pieces = <_Piece>[];
    for (var i = 0; i < count; i++) {
      final fromLeft = i.isEven;
      // 36..84 degrees above horizontal, aimed inward. A narrower fan left
      // two clumps hugging the corners with a bald strip down the middle;
      // the shallow end of this range is what carries paper across the
      // centre.
      final angle = (36 + random.nextDouble() * 48) * pi / 180;
      final speed = 1.5 + random.nextDouble() * 1.5;
      final vx = cos(angle) * speed * (fromLeft ? 1 : -1);
      pieces.add(
        _Piece(
          x0: fromLeft ? -0.02 : 1.02,
          y0: 1.04 + random.nextDouble() * 0.04,
          vx: vx,
          vy: -sin(angle) * speed,
          delay: random.nextDouble() * 0.12,
          size: 7 + random.nextDouble() * 9,
          // One in six is a streamer, which flutters rather than flips.
          aspect: random.nextInt(6) == 0
              ? 0.18 + random.nextDouble() * 0.08
              : 0.5 + random.nextDouble() * 0.25,
          spin: (random.nextDouble() - 0.5) * 2.4,
          flipRate: 1.6 + random.nextDouble() * 2.8,
          flipPhase: random.nextDouble() * 2 * pi,
          colorIndex: random.nextInt(4),
        ),
      );
    }
    return pieces;
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({
    required this.pieces,
    required this.progress,
    required this.seconds,
    required this.colors,
  });

  final List<_Piece> pieces;
  final double progress;

  /// The burst's length in seconds, so the physics runs in real time rather
  /// than against a 0..1 ramp.
  final double seconds;

  final List<Color> colors;

  /// Downward pull and air resistance, both in box fractions per second.
  /// Terminal speed is [_gravity] / [_drag] — about two thirds of the box a
  /// second, which is roughly how fast a scrap of paper actually falls.
  static const double _gravity = 1.55;
  static const double _drag = 1.8;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final now = progress * seconds;

    for (final piece in pieces) {
      final t = now - piece.delay;
      if (t <= 0) continue;

      // Projectile with linear drag, integrated rather than stepped, so the
      // path does not depend on the frame rate.
      final decay = 1 - exp(-_drag * t);
      final dx = piece.x0 + piece.vx * decay / _drag;
      final dy = piece.y0 +
          (piece.vy - _gravity / _drag) * decay / _drag +
          _gravity * t / _drag;

      if (dy > 1.25) continue;

      // Fades over the last fifth of the burst, so nothing blinks out.
      final life = (t / (seconds - piece.delay)).clamp(0.0, 1.0);
      final opacity = life < 0.8 ? 1.0 : (1 - life) / 0.2;
      if (opacity <= 0) continue;

      paint.color = colors[piece.colorIndex].withValues(alpha: opacity);

      final long = piece.size;
      final short = long * piece.aspect;
      // |cos| of the tumble: edge-on twice a turn. Floored so a piece thins
      // to a line instead of disappearing for a frame.
      final flip = max((cos(piece.flipPhase + t * piece.flipRate * 2 * pi)).abs(), 0.12);

      canvas.save();
      canvas.translate(dx * size.width, dy * size.height);
      canvas.rotate(piece.spin * t * 2 * pi);
      canvas.scale(1, flip);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: long,
          height: short,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.progress != progress || old.colors != colors;
}
