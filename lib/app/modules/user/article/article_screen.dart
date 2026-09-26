import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/article.dart';
import 'controller/article_controller.dart';

/// The article reader — Figma "Pilates & Core Articles" (`259:58647`) and
/// "Stretch Articles" (`259:58687`).
///
/// Measured below the status bar: the header 69, the cover 123 (318 tall,
/// 344 wide), the title 465.5 over two lines at a 32 pitch with the rating
/// on its first line, the body 535 at a 19 pitch, and the call to action 692.
///
/// The frames' own cover is a stock poster mock-up ("POSTER A4 / Plastic
/// Surgery"); each article draws its section's photograph instead. See
/// [Article.coverAsset].
class ArticleScreen extends GetView<ArticleController> {
  const ArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final article = controller.article;
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
                      imagePath: article.coverAsset,
                      height: 318.v,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 24.5.v),
                  _TitleRow(article: article),
                  SizedBox(height: 22.5.v),
                  Text(article.body, style: CustomTextStyles.articleBody),
                  SizedBox(height: 33.v),
                  _CallToAction(article: article),
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
  const _TitleRow({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 84.h),
          child: Text(article.title, style: CustomTextStyles.articleTitle),
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
                '${article.rating}/5',
                style: CustomTextStyles.articleRating,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The closing paragraph, with its two phrases tappable.
///
/// Stateful only because a [TapGestureRecognizer] has to be disposed — one
/// built inline in `build` leaks a recognizer on every rebuild.
class _CallToAction extends StatefulWidget {
  const _CallToAction({required this.article});

  final Article article;

  @override
  State<_CallToAction> createState() => _CallToActionState();
}

class _CallToActionState extends State<_CallToAction> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void initState() {
    super.initState();
    final controller = Get.find<ArticleController>();
    for (final run in widget.article.callToAction) {
      if (run.link == null) continue;
      _recognizers.add(
        TapGestureRecognizer()..onTap = () => controller.follow(run.link!),
      );
    }
  }

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var next = 0;
    return Text.rich(
      TextSpan(
        children: [
          for (final run in widget.article.callToAction)
            if (run.isLink)
              TextSpan(
                text: run.text,
                style: CustomTextStyles.articleLink,
                recognizer: _recognizers[next++],
              )
            else
              TextSpan(text: run.text, style: CustomTextStyles.articleBody),
        ],
      ),
    );
  }
}
