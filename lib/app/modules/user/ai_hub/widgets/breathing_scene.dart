import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The AI Hub's backdrop — a night sky over water with a glowing droplet.
///
/// Painted rather than shipped as a PNG. The frames bake the "Tap Droplet or
/// Chat to Expand" label into the artwork, so a crop would carry a label that
/// cannot be changed, localised or removed once the panel expands. Painting it
/// also gives the droplet its bob for free, which is the whole point of the
/// copy: "try breathing in sync with its gentle bobbing".
///
/// Colours are sampled from the rendered frames (page 124:2, `176:56425`).
class BreathingScene extends StatelessWidget {
  const BreathingScene({super.key, required this.phase});

  /// 0..1 through one breath. Drives how far the droplet has risen.
  final double phase;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _ScenePainter(phase),
        size: Size.infinite,
      );
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.phase);

  final double phase;

  // Sampled down the left edge of the panel, away from the droplet's glow.
  static const _sky = [
    (0.00, Color(0xFF121F4B)),
    (0.10, Color(0xFF042F64)),
    (0.20, Color(0xFF033D6C)),
    (0.30, Color(0xFF044A7A)),
    (0.40, Color(0xFF055889)),
    (0.52, Color(0xFF0666AE)),
    (0.56, Color(0xFF043F74)),
    (0.62, Color(0xFF022B58)),
    (0.72, Color(0xFF022156)),
    (1.00, Color(0xFF021F5B)),
  ];

  /// The scene is composed at the panel's proportions and scaled to cover
  /// whatever box it is given, so the droplet keeps its shape and its size
  /// relative to the artwork whether it is drawn in the 341x233 panel or
  /// filling the screen behind the chat.
  static const design = Size(341.5, 233);

  /// Where the waterline sits in the design box, and where it should land in
  /// whatever box the scene is given.
  static const _horizon = 0.545;
  static const _horizonAt = 0.55;

  @override
  void paint(Canvas canvas, Size box) {
    // Scaled by width, not to cover. Cover made the droplet balloon to a
    // quarter of the screen once the chat took the full height; the frames
    // keep it the same size in both, and grow the sky instead.
    final scale = box.width / design.width;

    canvas.save();
    canvas.clipRect(Offset.zero & box);
    canvas.scale(scale);
    // Line the waterline up with the same fraction of the box in both
    // states, so the horizon does not jump as the panel expands.
    canvas.translate(
      0,
      (box.height * _horizonAt - design.height * _horizon * scale) / scale,
    );

    // Backgrounds are drawn well outside the design box and clipped, so a
    // box of any shape is filled; every feature stays in design units.
    final bleed = Rect.fromLTWH(
      -design.width,
      -design.height * 2,
      design.width * 3,
      design.height * 5,
    );

    canvas.drawRect(
      bleed,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [for (final s in _sky) s.$2],
          stops: [for (final s in _sky) s.$1],
        ).createShader(Offset.zero & design),
    );

    _wave(canvas, bleed, from: 0.545, dip: 0.585, to: 0.540,
        color: const Color(0xFF0C5DA4), crest: const Color(0x4D9FD9F6));
    _wave(canvas, bleed, from: 0.640, dip: 0.680, to: 0.615,
        color: const Color(0xFF073F7C), crest: const Color(0x338FCBEE));
    _wave(canvas, bleed, from: 0.800, dip: 0.755, to: 0.820,
        color: const Color(0xFF04255A));

    _horizonGlow(canvas);
    _droplet(canvas);
    canvas.restore();
  }

  /// The bright streak along the waterline. It runs the full width, brightest
  /// under the droplet — in the frame it is the strongest thing on screen
  /// after the droplet itself.
  void _horizonGlow(Canvas canvas) {
    final horizon = design.height * 0.545;

    final wide = Rect.fromCenter(
      center: Offset(design.width / 2, horizon),
      width: design.width * 1.9,
      height: design.height * 0.20,
    );
    canvas.drawOval(
      wide,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0xB37FD4FF), Color(0x00000000)],
        ).createShader(wide),
    );

    final core = Rect.fromCenter(
      center: Offset(design.width / 2, horizon),
      width: design.width * 0.62,
      height: design.height * 0.10,
    );
    canvas.drawOval(
      core,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0xCCD6F1FF), Color(0x00000000)],
        ).createShader(core),
    );
  }

  void _droplet(Canvas canvas) {
    // Rises and settles by a fraction of its own height, so the bob reads the
    // same whatever size the scene is drawn at.
    final lift = math.sin(phase * 2 * math.pi) * design.height * 0.012;
    final centre =
        Offset(design.width / 2, design.height * 0.425 - lift);
    final w = design.width * 0.205;
    // 70x86 in the frame.
    final h = w * 86 / 70;
    final egg = Rect.fromCenter(center: centre, width: w, height: h);

    final halo = Rect.fromCenter(
      center: centre.translate(0, h * 0.14),
      width: w * 3.1,
      height: h * 1.5,
    );
    canvas.drawOval(
      halo,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0x8055C0F4), Color(0x00000000)],
          stops: const [0.20, 1.0],
        ).createShader(halo),
    );

    canvas.drawOval(
      egg,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.55),
          radius: 0.85,
          // Translucent, not a white blob: in the frame the egg is mostly
          // its outline with the light gathered near the base.
          colors: const [
            Color(0xE0E8F6FF),
            Color(0x9EA6DBF8),
            Color(0x2E42A8E8),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(egg),
    );

    canvas.drawOval(
      egg,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x80FFFFFF),
    );

    canvas.drawCircle(
      centre.translate(-w * 0.11, -h * 0.20),
      w * 0.070,
      Paint()..color = const Color(0xE6FFFFFF),
    );
  }

  /// A band of water: a single curve across the panel, filled to the bottom.
  void _wave(
    Canvas canvas,
    Rect bleed, {
    required double from,
    required double dip,
    required double to,
    required Color color,
    Color? crest,
  }) {
    // The curve spans the design width; beyond it the band simply continues,
    // which is all a wider box needs.
    final path = Path()
      ..moveTo(bleed.left, design.height * from)
      ..lineTo(0, design.height * from)
      ..quadraticBezierTo(
        design.width / 2,
        design.height * dip,
        design.width,
        design.height * to,
      )
      ..lineTo(bleed.right, design.height * to)
      ..lineTo(bleed.right, bleed.bottom)
      ..lineTo(bleed.left, bleed.bottom)
      ..close();
    canvas.drawPath(path, Paint()..color = color);

    // A hairline along the crest. Without it the bands merge into one dark
    // mass and the water stops reading as water.
    if (crest != null) {
      final edge = Path()
        ..moveTo(bleed.left, design.height * from)
        ..lineTo(0, design.height * from)
        ..quadraticBezierTo(
          design.width / 2,
          design.height * dip,
          design.width,
          design.height * to,
        )
        ..lineTo(bleed.right, design.height * to);
      canvas.drawPath(
        edge,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = crest,
      );
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.phase != phase;
}

/// [BreathingScene] with its breath running.
///
/// One cycle is the pace the copy asks the user to follow, so it is slow on
/// purpose. Reduce-motion stops it outright — a scene that never stops moving
/// is exactly what that setting exists to switch off, and it is also what
/// keeps anything waiting on a still frame from ever settling.
class BreathingSceneLoop extends StatefulWidget {
  const BreathingSceneLoop({super.key, this.playing = true});

  final bool playing;

  static const period = Duration(seconds: 8);

  @override
  State<BreathingSceneLoop> createState() => _BreathingSceneLoopState();
}

class _BreathingSceneLoopState extends State<BreathingSceneLoop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: BreathingSceneLoop.period,
  );

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context) || !widget.playing;
    if (still) {
      if (_breath.isAnimating) _breath.stop();
    } else if (!_breath.isAnimating) {
      _breath.repeat();
    }

    return AnimatedBuilder(
      animation: _breath,
      builder: (context, _) => BreathingScene(phase: _breath.value),
    );
  }
}
