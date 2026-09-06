import 'package:flutter/material.dart';

import '../../../../../core/app_export.dart';

/// The floating AI Therapy Assist button — 70x70, drawn from its export.
///
/// It drifts gently up and down while idle, and can be dragged anywhere on
/// the screen. Both matter for a button that sits over scrolling content: the
/// drift marks it as live rather than a sticker, and dragging lets the user
/// move it off whatever it is covering.
class AiAssistButton extends StatefulWidget {
  const AiAssistButton({
    super.key,
    required this.onTap,
    this.size = 70,
    this.bounds = Size.zero,
  });

  final VoidCallback onTap;

  final double size;

  /// The area the button may be dragged within. Zero leaves it unclamped,
  /// which is only useful before the first layout.
  final Size bounds;

  /// How far it drifts either side of its resting point.
  static const drift = 6.0;

  static const driftPeriod = Duration(milliseconds: 2400);

  @override
  State<AiAssistButton> createState() => _AiAssistButtonState();
}

class _AiAssistButtonState extends State<AiAssistButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: AiAssistButton.driftPeriod,
  );

  /// Where the user has dragged it to, from the top-left of [bounds]. Null
  /// until the first drag, so the button keeps its designed resting place.
  Offset? _position;

  /// Suspended while dragging — a button that bobs under the finger feels
  /// like it is slipping.
  bool _dragging = false;

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  Offset get _resting {
    final b = widget.bounds;
    // The design rests it bottom-right, 4 in and 16 up.
    return Offset(
      b.width - widget.size - 4.h,
      b.height - widget.size - 16.v,
    );
  }

  void _onDrag(DragUpdateDetails details) {
    final b = widget.bounds;
    final next = (_position ?? _resting) + details.delta;
    setState(() {
      _dragging = true;
      _position = Offset(
        next.dx.clamp(0.0, (b.width - widget.size).clamp(0.0, double.infinity)),
        next.dy
            .clamp(0.0, (b.height - widget.size).clamp(0.0, double.infinity)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final at = _position ?? _resting;

    // Reduce motion stops the drift outright. A button that bobs forever is
    // exactly the kind of movement that setting exists to switch off — and it
    // is also what makes the widget never settle, so anything waiting on a
    // still frame (a test, a screenshot) hangs on it.
    if (MediaQuery.disableAnimationsOf(context)) {
      if (_float.isAnimating) _float.stop();
      return Positioned(left: at.dx, top: at.dy, child: _button());
    }
    if (!_float.isAnimating) _float.repeat(reverse: true);

    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        // A full sine cycle over the period, so the turn at each end eases
        // rather than snapping.
        final t = Curves.easeInOut.transform(_float.value);
        final dy = _dragging ? 0.0 : (t - 0.5) * 2 * AiAssistButton.drift;
        // Clamped after the drift, not just after the drag: parked against an
        // edge, the drift alone would carry it off-screen.
        final maxY = (widget.bounds.height - widget.size)
            .clamp(0.0, double.infinity);
        final top = (at.dy + dy).clamp(0.0, maxY);
        return Positioned(left: at.dx, top: top, child: child!);
      },
      child: _button(),
    );
  }

  Widget _button() => GestureDetector(
        onTap: widget.onTap,
        onPanUpdate: _onDrag,
        onPanEnd: (_) => setState(() => _dragging = false),
        // The export is the whole button — white disc, shadow and glyph — so
        // it is drawn at full size rather than as a glyph inside a circle.
        child: CustomImageView(
          imagePath: ImageConstant.imgAiAssistIcon,
          height: widget.size.h,
          width: widget.size.h,
        ),
      );
}
