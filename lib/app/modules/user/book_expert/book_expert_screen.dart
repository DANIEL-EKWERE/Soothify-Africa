import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/expert_session_type.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/gradient_text.dart';
import 'controller/book_expert_controller.dart';

/// "Book a licensed expert screen" — Figma `259:31488`, dark twin
/// `259:31885`.
///
/// Measured off the frame: a 24-square back chevron at (24, 64) with
/// "Schedule" centred on the same line, the two-line heading at 139 on the
/// `#2F6FED -> #274889` run, then three 342-square cards from 215 at a 366
/// pitch — a 24 gap.
///
/// Inside a card, everything is inset 24: a 294x150 photograph with an 8
/// radius, the title 16 below it, the blurb 4 under that, and a 294x48 action
/// 16 lower, leaving 24 to the card's foot. The card itself is `#FEFEFE`
/// under a 1px `#2233B5` hairline at a 16 radius.
///
/// The frame is 1330 tall against an 844 viewport, so the screen scrolls.
class BookExpertScreen extends GetView<BookExpertController> {
  const BookExpertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 17.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: Get.back,
                    child: CustomImageView(
                      imagePath: ImageConstant.icBack,
                      height: 24.h,
                      width: 24.h,
                      color: appTheme.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Schedule',
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.appBarTitle,
                    ),
                  ),
                  SizedBox(width: 24.h),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 51.v, 24.h, 41.v),
                children: [
                  GradientText(
                    'Schedule live sessions\nwith experts',
                    gradient: appTheme.authHeaderGradient,
                    style: CustomTextStyles.kycQuestion,
                  ),
                  SizedBox(height: 24.v),
                  for (final offer in controller.offers) ...[
                    _OfferCard(offer: offer),
                    if (offer != controller.offers.last)
                      SizedBox(height: 24.v),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});

  final ExpertSessionType offer;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookExpertController>();
    return Container(
      padding: EdgeInsets.all(24.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(16.h),
        // The hairline is #2233B5 — the same blue as the action fill,
        // which the palette already carries.
        border: Border.all(color: appTheme.actionFill),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomImageView(
            imagePath: offer.assetPath,
            height: 150.v,
            width: double.infinity,
            fit: BoxFit.cover,
            radius: BorderRadius.circular(8.h),
          ),
          SizedBox(height: 16.v),
          Text(offer.title, style: CustomTextStyles.expertOfferTitle),
          SizedBox(height: 4.v),
          Text(offer.blurb, style: CustomTextStyles.expertOfferBlurb),
          SizedBox(height: 16.v),
          // 48 rather than the app's usual 52: this is a card action, and
          // the frame draws it shorter. Everything else — the #2233B5 fill,
          // the 8 radius, Nunito Sans 800 18 in white — is already the
          // default.
          CustomElevatedButton(
            text: 'Book session',
            height: 48,
            onPressed: () => controller.book(offer),
          ),
        ],
      ),
    );
  }
}
