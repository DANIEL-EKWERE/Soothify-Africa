import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/wellness_space.dart';
import '../../../widgets/custom_elevated_button.dart';
import 'widgets/space_card.dart';

/// "Studio Profile & Direct Connect Screen" — Figma `282:25339`.
///
/// A 390x318 photograph with a "1/5" counter at (321, 236), then a sheet from
/// 306 carrying a 36x4 grab handle at 318, a 73-square avatar at (25, 342)
/// beside the name and location, the tags at 393, the blurb at 427, a row of
/// three 108x95 gallery frames at 489, the two actions at 608.5 and 668.5,
/// and a 12pt teaser at 745.
class StudioProfileScreen extends StatelessWidget {
  const StudioProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final space = Get.arguments is WellnessSpace
        ? Get.arguments as WellnessSpace
        : WellnessSpace.sample.first;

    return Scaffold(
      backgroundColor: appTheme.background,
      body: Stack(
        children: [
          CustomImageView(
            imagePath: space.photo,
            height: 318.v,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            left: 24.h,
            top: 70.v,
            child: Row(
              children: [
                InkWell(
                  onTap: Get.back,
                  child: CustomImageView(
                    imagePath: ImageConstant.icBack,
                    height: 24.h,
                    width: 24.h,
                    color: appTheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 321.h,
            top: 236.v,
            child: const _Counter(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _Sheet(space: space),
          ),
        ],
      ),
    );
  }
}

/// "1/5" over the photograph — 45x27 on ink at 72%.
class _Counter extends StatelessWidget {
  const _Counter();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 27.v,
      width: 45.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: appTheme.textPrimary.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Text('1/5', style: CustomTextStyles.studioCounter),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.space});

  final WellnessSpace space;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 533.v,
      decoration: BoxDecoration(color: appTheme.onPrimary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 12.v),
          Center(
            child: Container(
              height: 4.v,
              width: 36.h,
              decoration: BoxDecoration(
                color: appTheme.sheetHandle,
                borderRadius: BorderRadius.circular(4.h),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(24.h, 20.v, 24.h, 24.v),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomImageView(
                      imagePath: space.photo,
                      height: 73.h,
                      width: 73.h,
                      fit: BoxFit.cover,
                      radius: BorderRadius.circular(3.65.h),
                    ),
                    SizedBox(width: 18.h),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(space.name, style: CustomTextStyles.spaceName),
                          SizedBox(height: 8.v),
                          // The frame separates these with an asterisk.
                          Text(
                            '${space.area} • '
                            '${space.distanceKm.toStringAsFixed(0)}km',
                            style: CustomTextStyles.studioLocation,
                          ),
                          SizedBox(height: 8.v),
                          Wrap(
                            spacing: 8.h,
                            runSpacing: 4.v,
                            children: [
                              for (final t in space.tags) SpaceTag(t),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.v),
                Text(space.about, style: CustomTextStyles.studioAbout),
                SizedBox(height: 24.v),
                SizedBox(
                  height: 95.v,
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        Expanded(
                          child: CustomImageView(
                            imagePath: space.photo,
                            height: 95.v,
                            fit: BoxFit.cover,
                            radius: BorderRadius.circular(8.h),
                          ),
                        ),
                        if (i < 2) SizedBox(width: 8.h),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 24.5.v),
                CustomElevatedButton(
                  text: 'Connect on Instagram',
                  onPressed: () => AppFeedback.info(
                    'Opening @${space.instagram} is not wired up yet.',
                  ),
                ),
                SizedBox(height: 8.v),
                CustomElevatedButton(
                  text: 'Call Studio Desk',
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.surface,
                    foregroundColor: appTheme.actionFill,
                    elevation: 0,
                    side: BorderSide(color: appTheme.actionFill),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.h),
                    ),
                  ),
                  labelStyle: CustomTextStyles.studioSecondaryAction,
                  onPressed: () => AppFeedback.info(
                    'Calling ${space.phone} is not wired up yet.',
                  ),
                ),
                SizedBox(height: 24.5.v),
                const _PassportTeaser(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Love this studio? Get early access to Passport passes".
///
/// The frame styles this as one text node with two runs — the question in
/// body ink and everything from "Get" in `#2F6FED`, which makes the second
/// half a link. It carries no prototype interaction and **the file has no
/// Passport screen**, so the destination does not exist yet; tapping says so
/// rather than doing nothing, which is what a blue phrase promises.
class _PassportTeaser extends StatelessWidget {
  const _PassportTeaser();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppFeedback.info(
        'Passport passes are not open yet — we’ll let you know when they are.',
      ),
      behavior: HitTestBehavior.opaque,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Love this studio? ',
              style: CustomTextStyles.studioTeaser,
            ),
            TextSpan(
              text: 'Get early access to Passport passes',
              style: CustomTextStyles.studioTeaserLink,
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
