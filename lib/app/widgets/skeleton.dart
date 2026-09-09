import 'dart:async';

import 'package:flutter/material.dart';

import '../core/utils/size_utils.dart';
import '../theme/theme_helper.dart';

/// A placeholder block shaped like the thing that is still loading.
///
/// Screens used to show either a bare spinner or nothing at all, so a slow
/// load looked like an empty screen. A skeleton keeps the layout still while
/// the data arrives, which is what stops content jumping into place.
class Skeleton extends StatelessWidget {
  const Skeleton({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  /// A line of text — thinner and softer-cornered than a block.
  const Skeleton.text({
    super.key,
    required this.width,
    this.height = 12,
  }) : radius = 6;

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: width.h,
        height: height.v,
        decoration: BoxDecoration(
          color: appTheme.skeleton,
          borderRadius: BorderRadius.circular(radius.h),
        ),
      );
}

/// Sweeps a soft highlight across whatever skeletons it wraps.
///
/// One controller for a whole screenful rather than one per block, so twenty
/// placeholders cost a single ticker and sweep in step.
///
/// Reduce-motion leaves the blocks flat. That setting exists for exactly this
/// kind of decorative, endless movement — and a shimmer that never stops is
/// also what would hang anything waiting on a still frame.
class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({super.key, required this.child});

  final Widget child;

  static const period = Duration(milliseconds: 1400);

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  // Built in initState, not lazily: a `late final` field that the build
  // skips under reduce-motion would be constructed for the first time by
  // dispose(), which then looks up a ticker on a dead element and throws.
  late final AnimationController _sweep;

  @override
  void initState() {
    super.initState();
    _sweep = AnimationController(
      vsync: this,
      duration: SkeletonShimmer.period,
    );
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      if (_sweep.isAnimating) _sweep.stop();
      return widget.child;
    }
    if (!_sweep.isAnimating) _sweep.repeat();

    return AnimatedBuilder(
      animation: _sweep,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) {
          // The band travels from off the left edge to off the right, so the
          // sweep enters and leaves rather than appearing mid-screen.
          final t = _sweep.value * 3 - 1;
          return LinearGradient(
            begin: Alignment(t - 0.6, 0),
            end: Alignment(t + 0.6, 0),
            colors: [
              appTheme.skeleton,
              appTheme.skeletonHighlight,
              appTheme.skeleton,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds);
        },
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Fades and lifts its child in the first time it appears.
///
/// Used where a skeleton gives way to real content, so the swap reads as the
/// content arriving rather than as a flicker.
class ContentReveal extends StatefulWidget {
  const ContentReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;

  /// Staggers a list: each row waits a little longer than the one above it.
  final Duration delay;

  static const duration = Duration(milliseconds: 320);

  @override
  State<ContentReveal> createState() => _ContentRevealState();
}

class _ContentRevealState extends State<ContentReveal>
    with SingleTickerProviderStateMixin {
  /// Eager, for the same reason as [SkeletonShimmer]'s: under reduce-motion
  /// the build returns the child untouched, so a lazy field would be created
  /// by dispose() and blow up looking for its ticker.
  late final AnimationController _in;

  bool _started = false;

  /// Held so it can be cancelled: a row can be scrolled away — or the whole
  /// screen torn down — before its turn comes, and starting an animation on a
  /// deactivated element throws while it looks up its ticker.
  Timer? _pending;

  @override
  void initState() {
    super.initState();
    _in = AnimationController(
      vsync: this,
      duration: ContentReveal.duration,
    );
  }

  @override
  void dispose() {
    _pending?.cancel();
    _in.dispose();
    super.dispose();
  }

  void _start() {
    if (_started) return;
    _started = true;
    if (widget.delay == Duration.zero) {
      _in.forward();
      return;
    }
    _pending = Timer(widget.delay, () {
      if (mounted) _in.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    _start();

    final curve = CurvedAnimation(parent: _in, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curve),
        child: widget.child,
      ),
    );
  }
}
