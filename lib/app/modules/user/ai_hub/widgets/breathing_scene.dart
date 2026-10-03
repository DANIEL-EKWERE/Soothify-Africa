import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../data/models/environment_vibe.dart';

/// One scene's colours.
///
/// The frames paint a single night scene; the vibe picker under it changed
/// the readout and nothing else, so two of the three options were a label
/// with no consequence. These give each one a scene of its own.
///
/// All three stay mid-to-dark on purpose. The hint pill, the pause control
/// and the guide's name sit directly on this artwork in white, so a pale
/// scene would take them with it.
class ScenePalette {
  const ScenePalette({
    required this.sky,
    required this.waves,
    required this.glowWide,
    required this.glowCore,
    required this.halo,
    required this.droplet,
    required this.dropletStroke,
    required this.highlight,
  });

  /// Stop/colour pairs down the sky, top to bottom.
  final List<(double, Color)> sky;

  /// The three water bands, each a fill and an optional crest hairline.
  final List<(Color, Color?)> waves;

  final Color glowWide;
  final Color glowCore;
  final Color halo;

  /// The droplet's three radial stops, centre out.
  final List<Color> droplet;

  final Color dropletStroke;
  final Color highlight;

  /// The frame's own scene — sampled from the rendered artwork, so this one
  /// is measured rather than chosen. Dusk over deep water.
  static const eveningBreeze = ScenePalette(
    sky: [
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
    ],
    waves: [
      (Color(0xFF0C5DA4), Color(0x4D9FD9F6)),
      (Color(0xFF073F7C), Color(0x338FCBEE)),
      (Color(0xFF04255A), null),
    ],
    glowWide: Color(0xB37FD4FF),
    glowCore: Color(0xCCD6F1FF),
    halo: Color(0x8055C0F4),
    droplet: [Color(0xE0E8F6FF), Color(0x9EA6DBF8), Color(0x2E42A8E8)],
    dropletStroke: Color(0x80FFFFFF),
    highlight: Color(0xE6FFFFFF),
  );

  /// Low sun over warm water: plum overhead falling through rust to an amber
  /// band at the waterline.
  static const sunsetCalm = ScenePalette(
    sky: [
      (0.00, Color(0xFF2B2150)),
      (0.10, Color(0xFF4A2A55)),
      (0.20, Color(0xFF70374F)),
      (0.30, Color(0xFF9A4738)),
      (0.40, Color(0xFFC25A22)),
      (0.52, Color(0xFFE8872A)),
      (0.56, Color(0xFFB4521F)),
      (0.62, Color(0xFF7E3A2A)),
      (0.72, Color(0xFF4A2440)),
      (1.00, Color(0xFF35204A)),
    ],
    waves: [
      (Color(0xFFC2561E), Color(0x4DFFD9A0)),
      (Color(0xFF8A3A2A), Color(0x33FFC98A)),
      (Color(0xFF4A2442), null),
    ],
    glowWide: Color(0xB3FFB347),
    glowCore: Color(0xCCFFE2B0),
    halo: Color(0x80FF9A3C),
    droplet: [Color(0xE0FFF1E0), Color(0x9EFFD3A0), Color(0x2EE8903F)],
    dropletStroke: Color(0x80FFFFFF),
    highlight: Color(0xE6FFFFFF),
  );

  /// Early haze: the colour drained out of it, a pale band of light sitting
  /// on the water where the sun has not cleared yet.
  static const morningMist = ScenePalette(
    sky: [
      (0.00, Color(0xFF40566B)),
      (0.10, Color(0xFF4F6B80)),
      (0.20, Color(0xFF5E8095)),
      (0.30, Color(0xFF6F94A8)),
      (0.40, Color(0xFF83A9BA)),
      (0.52, Color(0xFF9CC3D1)),
      (0.56, Color(0xFF7A9DB0)),
      (0.62, Color(0xFF5F8194)),
      (0.72, Color(0xFF4A6A7D)),
      (1.00, Color(0xFF3C586B)),
    ],
    waves: [
      (Color(0xFF6B93A8), Color(0x4DFFFFFF)),
      (Color(0xFF527A90), Color(0x33E8F6FB)),
      (Color(0xFF3C5C70), null),
    ],
    glowWide: Color(0xB3D8EEF5),
    glowCore: Color(0xCCF2FAFD),
    halo: Color(0x6690C8DC),
    droplet: [Color(0xE0FFFFFF), Color(0x9EDCEEF6), Color(0x2E8FBED4)],
    dropletStroke: Color(0x80FFFFFF),
    highlight: Color(0xE6FFFFFF),
  );

  static ScenePalette of(EnvironmentVibe vibe) => switch (vibe) {
        EnvironmentVibe.sunsetCalm => sunsetCalm,
        EnvironmentVibe.morningMist => morningMist,
        EnvironmentVibe.eveningBreeze => eveningBreeze,
      };
}

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
  const BreathingScene({
    super.key,
    required this.phase,
    this.palette = ScenePalette.eveningBreeze,
  });

  /// 0..1 through one breath. Drives how far the droplet has risen.
  final double phase;

  final ScenePalette palette;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _ScenePainter(phase, palette),
        size: Size.infinite,
      );
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.phase, this.palette);

  final double phase;
  final ScenePalette palette;

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
          colors: [for (final s in palette.sky) s.$2],
          stops: [for (final s in palette.sky) s.$1],
        ).createShader(Offset.zero & design),
    );

    _wave(canvas, bleed, from: 0.545, dip: 0.585, to: 0.540,
        color: palette.waves[0].$1, crest: palette.waves[0].$2);
    _wave(canvas, bleed, from: 0.640, dip: 0.680, to: 0.615,
        color: palette.waves[1].$1, crest: palette.waves[1].$2);
    _wave(canvas, bleed, from: 0.800, dip: 0.755, to: 0.820,
        color: palette.waves[2].$1, crest: palette.waves[2].$2);

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
          colors: [palette.glowWide, const Color(0x00000000)],
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
          colors: [palette.glowCore, const Color(0x00000000)],
        ).createShader(core),
    );
  }

  void _droplet(Canvas canvas) {
    // Rises and settles by a fraction of its own height, so the bob reads the
    // same whatever size the scene is drawn at.
    // 0.032 of the scene's height, up from 0.012. At the old travel the
    // droplet moved about three pixels across a whole breath, which read as
    // a still image rather than something to breathe along with.
    final lift = math.sin(phase * 2 * math.pi) * design.height * 0.032;
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
          colors: [palette.halo, const Color(0x00000000)],
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
          colors: palette.droplet,
          stops: const [0.0, 0.45, 1.0],
        ).createShader(egg),
    );

    canvas.drawOval(
      egg,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = palette.dropletStroke,
    );

    canvas.drawCircle(
      centre.translate(-w * 0.11, -h * 0.20),
      w * 0.070,
      Paint()..color = palette.highlight,
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
  bool shouldRepaint(_ScenePainter old) =>
      old.phase != phase || old.palette != palette;
}

/// [BreathingScene] with its breath running.
///
/// One cycle is the pace the copy asks the user to follow, so it is slow on
/// purpose. Reduce-motion stops it outright — a scene that never stops moving
/// is exactly what that setting exists to switch off, and it is also what
/// keeps anything waiting on a still frame from ever settling.
class BreathingSceneLoop extends StatefulWidget {
  const BreathingSceneLoop({
    super.key,
    this.playing = true,
    this.palette = ScenePalette.eveningBreeze,
    this.period = defaultPeriod,
    this.onCycle,
  });

  final bool playing;

  final ScenePalette palette;

  /// One full breath. The readout beside the scene prints this as a pace, so
  /// the number on screen and the thing on screen cannot drift apart.
  final Duration period;

  /// Fired each time a breath completes. Driven by the ticker rather than a
  /// timer of its own, so reduce-motion stops the readings with the scene and
  /// nothing is left running for a test to wait on.
  final VoidCallback? onCycle;

  /// 6s, down from 8s — the droplet was drifting slowly enough to look still.
  static const defaultPeriod = Duration(seconds: 6);

  @override
  State<BreathingSceneLoop> createState() => _BreathingSceneLoopState();
}

class _BreathingSceneLoopState extends State<BreathingSceneLoop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  double _last = 0;

  @override
  void initState() {
    super.initState();
    _breath.addListener(_watchForWrap);
  }

  /// `repeat()` never reports completion, so a breath is counted by the value
  /// falling back to the start.
  void _watchForWrap() {
    if (_breath.value < _last) widget.onCycle?.call();
    _last = _breath.value;
  }

  @override
  void didUpdateWidget(BreathingSceneLoop old) {
    super.didUpdateWidget(old);
    if (widget.period != old.period) _breath.duration = widget.period;
  }

  @override
  void dispose() {
    _breath.removeListener(_watchForWrap);
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
      builder: (context, _) =>
          BreathingScene(phase: _breath.value, palette: widget.palette),
    );
  }
}
