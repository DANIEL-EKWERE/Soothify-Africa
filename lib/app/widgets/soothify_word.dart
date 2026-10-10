import 'package:flutter/material.dart';

/// The brand's name, with the smile under its two o's.
///
/// The wordmark draws a short arc beneath "oo" so the pair reads as eyes over
/// a mouth. Setting the name in plain type loses that, and the name appears
/// far more often in copy than it does as the logo — so this draws it back,
/// at whatever size and colour the surrounding text is using.
///
/// The arc is measured off the glyphs rather than guessed: a [TextPainter]
/// reports where "oo" actually sits, which keeps the mark aligned across font
/// sizes, weights and faces.
class SoothifyWord extends StatelessWidget {
  const SoothifyWord({super.key, this.style});

  /// Defaults to the surrounding text's style, which is what lets this sit
  /// inside a paragraph without being told anything.
  final TextStyle? style;

  static const word = 'Soothify';

  /// Builds [text] with every "Soothify" in it carrying the smile.
  ///
  /// Returns the spans for a [Text.rich]; the plain stretches stay ordinary
  /// text, so wrapping, selection and justification are unaffected.
  static List<InlineSpan> spansIn(String text, {TextStyle? style}) {
    final spans = <InlineSpan>[];
    var at = 0;
    while (true) {
      final found = text.indexOf(word, at);
      if (found < 0) {
        if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
        return spans;
      }
      if (found > at) spans.add(TextSpan(text: text.substring(at, found)));
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: SoothifyWord(style: style),
        ),
      );
      at = found + word.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolved = DefaultTextStyle.of(context).style.merge(style);
    return CustomPaint(
      painter: _Smile(style: resolved),
      // Excluded: the sentence around it supplies the name through its own
      // semantics label, so announcing it here would say it twice.
      child: ExcludeSemantics(
        child: Text(word, style: resolved, textAlign: TextAlign.left),
      ),
    );
  }
}

/// [Text], with the brand's smile drawn under any "Soothify" in the string.
///
/// A drop-in for `Text` at the call sites that print the name, so marking it
/// is a one-word change rather than a hand-built `Text.rich` each time.
class SoothifyText extends StatelessWidget {
  const SoothifyText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    if (!data.contains(SoothifyWord.word)) {
      return Text(
        data,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }
    return Text.rich(
      TextSpan(children: SoothifyWord.spansIn(data, style: style)),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      // The name rides in a WidgetSpan, which a screen reader announces as a
      // gap in the sentence. This hands assistive tech the plain string.
      semanticsLabel: data,
    );
  }
}

class _Smile extends CustomPainter {
  const _Smile({required this.style});

  final TextStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final painter = TextPainter(
      text: TextSpan(text: SoothifyWord.word, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    // The two o's — "S" is index 0, so they are 1 and 2.
    final boxes = painter.getBoxesForSelection(
      const TextSelection(baseOffset: 1, extentOffset: 3),
    );
    if (boxes.isEmpty) return;
    final left = boxes.first.left;
    final right = boxes.last.right;
    final baseline = painter.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    );

    final em = style.fontSize ?? 14;
    // Inset a little, so the mouth sits inside the eyes rather than running
    // the full width of both.
    final inset = (right - left) * 0.14;
    // Clear of the glyphs rather than tucked under them: at 0.06 the arc
    // nearly touched the o's and read as an underline.
    final top = baseline + em * 0.17;
    final depth = em * 0.16;

    canvas.drawPath(
      Path()
        ..moveTo(left + inset, top)
        ..quadraticBezierTo(
          (left + right) / 2,
          top + depth,
          right - inset,
          top,
        ),
      Paint()
        ..color = style.color ?? const Color(0xFF000000)
        ..strokeWidth = em * 0.07
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_Smile old) => old.style != style;
}
