import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/article.dart';
import '../../../data/models/article_body.dart';
import 'controller/article_controller.dart';

/// The article reader — Figma "Pilates & Core Articles" (`259:58647`) and
/// "Stretch Articles" (`259:58687`).
///
/// Measured below the status bar: the header 69, the cover 123 (318 tall,
/// 344 wide), the title 465.5 over two lines at a 32 pitch with the rating
/// on its first line, the body 535 at a 19 pitch, and the call to action 692.
///
/// The frames' own cover is a stock poster mock-up ("POSTER A4 / Plastic
/// Surgery"), so the article's own cover is drawn -- whatever was uploaded
/// with it.
class ArticleScreen extends GetView<ArticleController> {
  const ArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 22.v),
            const _Header(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 40.v, 24.h, 32.v),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.h),
                    child: CustomImageView(
                      imagePath: controller.cover,
                      height: 318.v,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 24.5.v),
                  const _TitleRow(),
                  SizedBox(height: 22.5.v),
                  const _Body(),
                  SizedBox(height: 33.v),
                  const _CallToAction(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Row(
        children: [
          InkWell(
            onTap: Get.back,
            child: CustomImageView(
              imagePath: ImageConstant.icBack,
              height: 18.h,
              width: 18.h,
              color: appTheme.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              'Articles',
              textAlign: TextAlign.center,
              style: CustomTextStyles.appBarTitle,
            ),
          ),
          SizedBox(width: 18.h),
        ],
      ),
    );
  }
}

/// The title wrapping under a rating pinned to the first line's right.
///
/// The frames set the rating beside the title rather than above it, so the
/// title has to flow around it — hence the leading inline space rather than a
/// Row, which would reserve the rating's width on every line.
class _TitleRow extends StatelessWidget {
  const _TitleRow();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 84.h),
          child: Text(Get.find<ArticleController>().title,
              style: CustomTextStyles.articleTitle),
        ),
        Positioned(
          right: 0,
          top: 4.v,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomImageView(
                imagePath: ImageConstant.icStar,
                height: 16.h,
                width: 16.h,
                color: appTheme.accent,
              ),
              SizedBox(width: 6.h),
              Text(
                '${Get.find<ArticleController>().rating}/5',
                style: CustomTextStyles.articleRating,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The article's own text, with any links the author embedded.
///
/// An author writes them inline on the dashboard, so a piece about winding
/// down can send the reader to the sleep story it is describing:
///
///     Wind down with [our Deep Rest story](media:42) tonight.
///
/// A body with no links renders as a plain [Text] — no recognizers to build
/// or dispose, which is the ordinary article and should cost nothing.
class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticleController>();
    if (!controller.bodyHasLinks) {
      return Text(controller.body, style: CustomTextStyles.articleBody);
    }
    return _LinkedProse(
      spans: controller.bodySpans,
      onTap: controller.followTap,
    );
  }
}

/// The closing paragraph, with its two phrases tappable.
class _CallToAction extends StatelessWidget {
  const _CallToAction();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticleController>();
    return _LinkedProse(
      // The generated call to action carries [ArticleLink]s rather than
      // body taps, so it is mapped onto the same shape -- one widget draws
      // both, and there is one place where a recognizer can leak.
      spans: [
        for (final run in controller.callToAction)
          ArticleSpan(
            run.text,
            tap: switch (run.link) {
              ArticleLink.library => const ArticleTap(ArticleTarget.library),
              ArticleLink.booking => const ArticleTap(ArticleTarget.booking),
              null => null,
            },
          ),
      ],
      onTap: controller.followTap,
    );
  }
}

/// Prose with tappable phrases in it.
///
/// Stateful only because a [TapGestureRecognizer] has to be disposed — one
/// built inline in `build` leaks a recognizer on every rebuild.
class _LinkedProse extends StatefulWidget {
  const _LinkedProse({required this.spans, required this.onTap});

  final List<ArticleSpan> spans;
  final void Function(ArticleTap) onTap;

  @override
  State<_LinkedProse> createState() => _LinkedProseState();
}

class _LinkedProseState extends State<_LinkedProse> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void initState() {
    super.initState();
    _build();
  }

  @override
  void didUpdateWidget(_LinkedProse old) {
    super.didUpdateWidget(old);
    // The spans can change under us -- a different article pushed onto the
    // same route. Recognizers are rebuilt rather than reused, or a tap
    // would follow the previous article's link.
    if (widget.spans.length != old.spans.length) {
      _dispose();
      _build();
    }
  }

  void _build() {
    for (final span in widget.spans) {
      final tap = span.tap;
      if (tap == null) continue;
      _recognizers.add(
        TapGestureRecognizer()..onTap = () => widget.onTap(tap),
      );
    }
  }

  void _dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var next = 0;
    return Text.rich(
      TextSpan(
        children: [
          for (final span in widget.spans)
            if (span.isLink)
              TextSpan(
                text: span.text,
                style: CustomTextStyles.articleLink,
                recognizer: _recognizers[next++],
              )
            else
              TextSpan(text: span.text, style: CustomTextStyles.articleBody),
        ],
      ),
    );
  }
}
