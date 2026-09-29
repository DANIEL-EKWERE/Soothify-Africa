import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

/// The three concentric discs on the joining screen — Figma `259:59996`.
///
/// 152.5 across in `#EDF6FE` inside a 2.9 hairline, 119.1 in `#2F6FED`, and
/// 77 in `#2F6FED` again. The frame stacks a `#E2EDFE` disc under the middle
/// one at the same size, which is how a still frame draws a pulse — so the
/// middle ring breathes between the two while the call connects.
class JoiningPulse extends StatefulWidget {
  const JoiningPulse({super.key});

  @override
  State<JoiningPulse> createState() => _JoiningPulseState();
}

class _JoiningPulseState extends State<JoiningPulse>
    with SingleTickerProviderStateMixin {
  // `late final`, but initState touches it below — which is what forces the
  // construction to happen there. Left to build alone, a reduce-motion path
  // that never reads it would have dispose construct it, and that throws.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    _pulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nothing is actually connecting, and a perpetual animation stops any
    // test that waits for a still frame from ever settling.
    final still = MediaQuery.disableAnimationsOf(context);
    if (still && _pulse.isAnimating) _pulse.stop();

    return SizedBox(
      width: 152.5.h,
      height: 152.5.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: appTheme.policyPanel,
              shape: BoxShape.circle,
              border: Border.all(color: appTheme.textPrimary, width: 2.9),
            ),
          ),
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) => Container(
              width: 119.1.h,
              height: 119.1.h,
              decoration: BoxDecoration(
                color: Color.lerp(
                  appTheme.trialBanner,
                  appTheme.soothifyBlue,
                  still ? 1 : _pulse.value,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: 77.h,
            height: 77.h,
            decoration: BoxDecoration(
              color: appTheme.soothifyBlue,
              shape: BoxShape.circle,
              border: Border.all(color: appTheme.textPrimary, width: 1.5),
            ),
            child: Icon(
              Icons.videocam_outlined,
              size: 32.h,
              color: appTheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
