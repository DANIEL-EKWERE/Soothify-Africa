import 'package:flutter/material.dart';

import 'soothify_word.dart';

/// Paints text with a gradient fill.
///
/// The onboarding title is gradient-filled in the design; a plain colour
/// would visibly flatten it.
///
/// Any "Soothify" in the string carries the wordmark's smile. The shader runs
/// over the whole subtree, so the mark is filled with the gradient along with
/// the letters — nothing extra to colour.
class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
    required this.style,
    this.textAlign,
  });

  final String text;
  final Gradient gradient;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: SoothifyText(
        text,
        textAlign: textAlign,
        // The shader supplies the colour; the base must be opaque for srcIn.
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
