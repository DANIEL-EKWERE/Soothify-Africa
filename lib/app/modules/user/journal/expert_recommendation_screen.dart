import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../core/app_export.dart';
import '../../../data/models/expert_recommendation.dart';
import 'controller/expert_recommendation_controller.dart';

/// One recommendation in full — Figma "Journal" (`259:60842`).
///
/// A pale card naming the expert and the session, the note they left inset
/// inside it, then the content they pointed the client at.
///
/// Measured: the expert card 114 (207 tall) with the note panel inset 13 and
/// 82 tall, the "Recommended Content" heading at 357.5, the content card 390
/// (318 tall) with its thumbnail 148 tall and a 39-tall action.
class ExpertRecommendationScreen
    extends GetView<ExpertRecommendationController> {
  const ExpertRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            ImageConstant.icChevronLeft,
            height: 24.h,
            width: 24.h,
            colorFilter:
                ColorFilter.mode(appTheme.textPrimary, BlendMode.srcIn),
          ),
          onPressed: Get.back,
        ),
        title: const Text('Journal'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(24.h, 24.v, 24.h, 32.v),
          children: [
            _ExpertCard(recommendation: controller.recommendation),
            SizedBox(height: 36.5.v),
            Text('Recommended Content', style: CustomTextStyles.shelfHeading),
            SizedBox(height: 20.5.v),
            _ContentCard(
              content: controller.recommendation.content,
              onOpen: controller.open,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpertCard extends StatelessWidget {
  const _ExpertCard({required this.recommendation});

  final ExpertRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(13.h),
      decoration: BoxDecoration(
        color: appTheme.policyPanel,
        borderRadius: BorderRadius.circular(8.h),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: CustomImageView(
                  imagePath: recommendation.avatarAsset,
                  height: 44.h,
                  width: 44.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 8.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.expertName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyles.expertName,
                    ),
                    SizedBox(height: 8.v),
                    Text(
                      recommendation.sessionLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyles.expertMeta,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.v),
          Padding(
            padding: EdgeInsets.only(left: 52.h),
            child: Text(
              DateFormat('MMM d, yyyy').format(recommendation.recordedAt),
              style: CustomTextStyles.expertMeta,
            ),
          ),
          SizedBox(height: 21.v),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(12.h, 11.v, 12.h, 13.v),
            decoration: BoxDecoration(
              // A second, deeper wash inside the card — the note is the
              // expert's words, not the app's.
              color: appTheme.trialBanner,
              borderRadius: BorderRadius.circular(6.h),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_square,
                      size: 18.h,
                      color: appTheme.soothifyBlue,
                    ),
                    SizedBox(width: 8.h),
                    Text('Expert’s Note',
                        style: CustomTextStyles.expertNoteLabel),
                  ],
                ),
                SizedBox(height: 6.v),
                Text(recommendation.note,
                    style: CustomTextStyles.expertNoteBody),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.content, required this.onOpen});

  final ExpertContent content;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(17.h),
      decoration: AppDecoration.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onOpen,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.h),
                  child: CustomImageView(
                    imagePath: content.coverAsset,
                    height: 148.v,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  width: 46.h,
                  height: 46.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: appTheme.onPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 26.h,
                    color: appTheme.soothifyBlue,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15.v),
          Row(
            children: [
              Icon(
                Icons.play_circle_outline,
                size: 16.h,
                color: appTheme.soothifyBlue,
              ),
              SizedBox(width: 6.h),
              Text(content.kind.label,
                  style: CustomTextStyles.expertContentKind),
            ],
          ),
          SizedBox(height: 11.v),
          Text(content.title, style: CustomTextStyles.expertContentTitle),
          SizedBox(height: 13.v),
          Text(content.meta, style: CustomTextStyles.expertMeta),
          SizedBox(height: 19.5.v),
          GestureDetector(
            onTap: onOpen,
            child: Container(
              height: 39.v,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appTheme.soothifyBlue,
                borderRadius: BorderRadius.circular(8.h),
              ),
              child: Text(
                content.kind.action,
                style: CustomTextStyles.expertContentTitle
                    .copyWith(color: appTheme.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
