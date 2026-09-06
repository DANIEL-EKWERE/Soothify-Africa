import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../core/app_export.dart';

/// The floating AI Therapy Assist button — 70x70, drawn from its export.
///
/// Behaves like a chat head: it drifts gently while idle, tracks the finger
/// exactly while dragged, and springs to the nearer edge on release carrying
/// whatever velocity the fling had. Both the drift and the settle matter for
/// a button that floats over scrolling content — the drift marks it as live,
/// and the settle keeps it off whatever it was covering.
class AiAssistButton extends StatefulWidget {
  const AiAssistButton({
    super.key,
    required this.onTap,
    this.size = 70,
    this.bounds = Size.zero,
  });

  final VoidCallback onTap;
  final double size;

  /// The area the button may be dragged within.
  final Size bounds;

  /// How far it drifts either side of its resting point.
  static const drift = 6.0;

  static const driftPeriod = Duration(milliseconds: 2400);

  /// Soft but decisive — overshoots a little, the way a chat head does.
  static const spring = SpringDescription(mass: 1, stiffness: 520, damping: 34);

  @override
  State<AiAssistButton> createState() => _AiAssistButtonState();
}

class _AiAssistButtonState extends State<AiAssistButton>
    with TickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: AiAssistButton.driftPeriod,
  );

  /// Drives the spring back to an edge. Unbounded because a spring overshoots
  /// past 1 before settling.
  late final AnimationController _settle = AnimationController.unbounded(
    vsync: this,
  );

  /// Where the button sits. A notifier rather than setState so a drag repaints
  /// only the Positioned — calling setState per pointer move rebuilt the whole
  /// subtree every frame, which is what made dragging feel heavy.
  final ValueNotifier<Offset?> _position = ValueNotifier(null);

  bool _dragging = false;
  Offset _springFrom = Offset.zero;
  Offset _springTo = Offset.zero;

  @override
  void initState() {
    super.initState();
    _settle.addListener(() {
      _position.value = Offset.lerp(_springFrom, _springTo, _settle.value);
    });
  }

  @override
  void dispose() {
    _settle.dispose();
    _float.dispose();
    _position.dispose();
    super.dispose();
  }

  Offset get _resting => Offset(
    widget.bounds.width - widget.size - 4.h,
    widget.bounds.height - widget.size - 16.v,
  );

  double get _maxX =>
      (widget.bounds.width - widget.size).clamp(0.0, double.infinity);

  double get _maxY =>
      (widget.bounds.height - widget.size).clamp(0.0, double.infinity);

  Offset _clamp(Offset o) =>
      Offset(o.dx.clamp(0.0, _maxX), o.dy.clamp(0.0, _maxY));

  void _onStart(DragStartDetails _) {
    _settle.stop();
    _dragging = true;
    _position.value ??= _resting;
  }

  void _onUpdate(DragUpdateDetails d) {
    // Straight to the notifier: no setState, so the finger never outruns it.
    _position.value = _clamp((_position.value ?? _resting) + d.delta);
  }

  void _onEnd(DragEndDetails d) {
    _dragging = false;
    final from = _position.value ?? _resting;
    final velocity = d.velocity.pixelsPerSecond;

    // The fling decides the edge, not just where the finger stopped — a throw
    // left from the right half should still land left.
    final projected = from.dx + widget.size / 2 + velocity.dx * 0.15;
    final toX = projected < widget.bounds.width / 2 ? 0.0 : _maxX;
    // Vertical momentum carries a little, then clamps inside the bounds.
    final toY = (from.dy + velocity.dy * 0.12).clamp(0.0, _maxY);
    final to = Offset(toX, toY);

    final distance = (to - from).distance;
    if (distance < 0.5) {
      _position.value = to;
      return;
    }

    // Seed the spring with the fling's speed along the travel direction, so a
    // hard throw arrives fast and a gentle nudge drifts over.
    final unit = (to - from) / distance;
    final along = velocity.dx * unit.dx + velocity.dy * unit.dy;

    _springFrom = from;
    _springTo = to;
    _settle
      ..value = 0
      ..animateWith(
        SpringSimulation(AiAssistButton.spring, 0, 1, along / distance),
      );
  }

  @override
  Widget build(BuildContext context) {
    // Reduce motion stops the drift outright. A button that bobs forever is
    // exactly the kind of movement that setting exists to switch off — and it
    // is also what makes the widget never settle, so anything waiting on a
    // still frame (a test, a screenshot) hangs on it.
    final still = MediaQuery.disableAnimationsOf(context);
    if (still) {
      if (_float.isAnimating) _float.stop();
    } else if (!_float.isAnimating) {
      _float.repeat(reverse: true);
    }

    return ValueListenableBuilder<Offset?>(
      valueListenable: _position,
      builder: (context, at, child) {
        final base = at ?? _resting;
        return AnimatedBuilder(
          animation: _float,
          builder: (context, inner) {
            final t = Curves.easeInOut.transform(_float.value);
            final dy = (still || _dragging)
                ? 0.0
                : (t - 0.5) * 2 * AiAssistButton.drift;
            // Clamped after the drift, not just after the drag: parked
            // against an edge, the drift alone would carry it off-screen.
            return Positioned(
              left: base.dx,
              top: (base.dy + dy).clamp(0.0, _maxY),
              child: inner!,
            );
          },
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onPanStart: _onStart,
        onPanUpdate: _onUpdate,
        onPanEnd: _onEnd,
        // The export is the whole button — white disc, shadow and glyph — so
        // it is drawn at full size rather than as a glyph inside a circle.
        child: CustomImageView(
          imagePath: ImageConstant.imgAiAssistIcon,
          height: widget.size.h,
          width: widget.size.h,
        ),
      ),
    );
  }
}
