import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/confetti_overlay.dart';
import '../../../widgets/gradient_text.dart';
import '../../../widgets/match_progress_bar.dart';
import 'controller/booking_controller.dart';
import 'widgets/matched_view.dart';

/// The booking flow after Schedule — Figma "Matching instructor" (135:20803),
/// "Communication method" (135:20817), "Audio call with instructor"
/// (135:20906), "Rating" (135:20850) and the feedback frame (135:20837).
///
/// One route with five stages: the frames share a header, run in a fixed
/// order, and back should retrace the flow rather than unwind a route stack.
class BookingScreen extends GetView<BookingController> {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      // The confetti sits outside the SafeArea so it falls past the status
      // bar and the home indicator rather than beginning and ending inside
      // the inset.
      body: Stack(
        children: [
          SafeArea(
            child: Obx(() {
              final stage = controller.stage.value;
              // The call screen has no header — a full-bleed call UI.
              if (stage == BookingStage.call) return const _CallStage();
              return Padding(
                padding: EdgeInsets.fromLTRB(24.h, 17.v, 24.h, 24.v),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Header(),
                    Expanded(
                      child: switch (stage) {
                        BookingStage.matching => const _MatchingStage(),
                        BookingStage.matched => const MatchedView(),
                        BookingStage.method => const _MethodStage(),
                        BookingStage.rating => const _RatingStage(),
                        BookingStage.feedback => const _FeedbackStage(),
                        BookingStage.call => const SizedBox.shrink(),
                      },
                    ),
                  ],
                ),
              );
            }),
          ),
          // Positioned.fill wraps the Obx rather than the other way round: a
          // Positioned has to be an immediate child of the Stack, and an Obx
          // returning one is not.
          //
          // Gated on the stage as well as the flag: tapping "Get started"
          // inside the 2.6s burst should not leave paper falling over the
          // communication picker.
          Positioned.fill(
            child: Obx(
              () => controller.celebrating.value &&
                      controller.stage.value == BookingStage.matched
                  ? ConfettiOverlay(onFinished: controller.celebrationShown)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();
    return Row(
      children: [
        InkWell(
          onTap: controller.back,
          child: CustomImageView(
            imagePath: ImageConstant.icBack,
            height: 18.h,
            width: 18.h,
            color: appTheme.textPrimary,
          ),
        ),
        Expanded(
          child: Text(
            'Book a Licensed Expert',
            textAlign: TextAlign.center,
            style: CustomTextStyles.appBarTitle,
          ),
        ),
        SizedBox(width: 18.h),
      ],
    );
  }
}

/// The matching interstitial — Figma `Matching pilates instructor`
/// (259:58806), the frame that closes each KYC row.
///
/// Redrawn from that frame, which moved it well down the screen and centred
/// it: the heading at 361 (Nunito Sans 700 20, centred, on the
/// `#2F6FED -> #274889` run), a 280.7x7 track at 411 with an 18.3 radius, and
/// a 10pt line at 434 across 242. The old file had it left-aligned near the
/// top at a much larger blurb size.
///
/// The heading names the discipline. Only the Pilates frame could be read —
/// see [SessionOffering.matchingTitle] — so the other two keep the old
/// generic line rather than a guess.
class _MatchingStage extends StatelessWidget {
  const _MatchingStage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();
    return Column(
      children: [
        SizedBox(height: 273.v),
        GradientText(
          controller.matchingHeading,
          gradient: appTheme.authHeaderGradient,
          textAlign: TextAlign.center,
          style: CustomTextStyles.kycQuestion,
        ),
        SizedBox(height: 24.v),
        Obx(() => MatchProgressBar(
              value: controller.matchProgress.value,
              // The frame draws this one's fill at 70%.
              fillOpacity: 0.7,
            )),
        SizedBox(height: 16.v),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 54.h),
          child: GradientText(
            // The frame's own string is 65 characters and stops mid-word:
            // `"We are matching you with someone who fits what you're
            // looking fo` — with the opening quote never closed. Finished
            // here, as the receipt's scrambled line was.
            'We are matching you with someone who fits what you’re looking '
            'for.',
            gradient: appTheme.authHeaderGradient,
            textAlign: TextAlign.center,
            style: CustomTextStyles.matchingCaption,
          ),
        ),
      ],
    );
  }
}

class _MethodStage extends StatelessWidget {
  const _MethodStage();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 51.v),
        GradientText(
          'How would you like to\nconnect with your wellness coach?',
          gradient: appTheme.authHeaderGradient,
          style: CustomTextStyles.kycQuestion,
        ),
        SizedBox(height: 8.v),
        Text(
          'We want to make sure it’s a comfortable and convenient '
          'experience for you.',
          style: CustomTextStyles.methodBlurb,
        ),
        SizedBox(height: 40.v),
        Row(
          children: [
            for (final m in CallMode.values) ...[
              Expanded(child: _MethodCard(mode: m)),
              if (m != CallMode.values.last) SizedBox(width: 20.h),
            ],
          ],
        ),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({required this.mode});

  final CallMode mode;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();
    return InkWell(
      onTap: () => controller.chooseMode(mode),
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 145.v,
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(bottom: 12.v),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(color: appTheme.optionBorder),
        ),
        child: GradientText(
          mode.label,
          gradient: appTheme.authHeaderGradient,
          textAlign: TextAlign.center,
          style: CustomTextStyles.featureBody,
        ),
      ),
    );
  }
}

class _CallStage extends StatelessWidget {
  const _CallStage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();
    return Column(
      children: [
        SizedBox(height: 117.v),
        ClipOval(
          child: CustomImageView(
            imagePath: ImageConstant.imgCoachCallAvatar,
            height: 100.h,
            width: 100.h,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 33.v),
        Text(controller.coachName, style: CustomTextStyles.callName),
        SizedBox(height: 8.v),
        Text('0:30', style: CustomTextStyles.callName),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CallButton(
              icon: Icons.mic_none,
              onTap: () {},
              fill: appTheme.surfaceAlt,
            ),
            SizedBox(width: 27.h),
            _CallButton(
              icon: Icons.videocam_outlined,
              onTap: () {},
              fill: appTheme.surfaceAlt,
            ),
            SizedBox(width: 27.h),
            _CallButton(
              icon: Icons.call_end,
              onTap: controller.endCall,
              fill: appTheme.error,
              tint: appTheme.onPrimary,
            ),
          ],
        ),
        SizedBox(height: 60.v),
      ],
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.icon,
    required this.onTap,
    required this.fill,
    this.tint,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color fill;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 53.h,
        height: 53.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
        // Call controls were not exported; Material stands in for these three.
        child: Icon(icon, size: 30.h, color: tint ?? appTheme.textPrimary),
      ),
    );
  }
}

class _RatingStage extends StatelessWidget {
  const _RatingStage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 51.v),
        GradientText(
          'We hope you enjoyed your session. How would you rate your '
          'experience with your instructor?',
          gradient: appTheme.authHeaderGradient,
          style: CustomTextStyles.kycQuestion,
        ),
        SizedBox(height: 48.v),
        // The frame stops at the question — it draws no input at all. A
        // five-star row is added so the screen can actually be answered;
        // confirm the intended control with the designer.
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 1; i <= 5; i++)
                  InkWell(
                    onTap: () => controller.rate(i),
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.h),
                      child: CustomImageView(
                        imagePath: ImageConstant.icStar,
                        height: 36.h,
                        width: 36.h,
                        color: i <= controller.rating.value
                            ? appTheme.accent
                            : appTheme.progressTrack,
                      ),
                    ),
                  ),
              ],
            )),
      ],
    );
  }
}

class _FeedbackStage extends StatelessWidget {
  const _FeedbackStage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 51.v),
        GradientText(
          "We'd love to hear about your experience! Could you please tell us "
          'how your live session went?',
          gradient: appTheme.authHeaderGradient,
          style: CustomTextStyles.kycQuestion,
        ),
        SizedBox(height: 29.v),
        Container(
          height: 161.v,
          padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 8.v),
          decoration: BoxDecoration(
            color: appTheme.fieldFill,
            borderRadius: BorderRadius.circular(8.h),
            border: Border.all(color: appTheme.navInactive),
          ),
          child: TextField(
            controller: controller.feedback,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: CustomTextStyles.topicChip,
            decoration: InputDecoration(
              hintText: 'Write......',
              hintStyle: CustomTextStyles.pillLabel
                  .copyWith(color: appTheme.navInactive),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10.h),
            ),
          ),
        ),
        SizedBox(height: 24.v),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: controller.post,
            borderRadius: BorderRadius.circular(8.h),
            child: Container(
              width: 89.h,
              height: 42.v,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appTheme.surface,
                borderRadius: BorderRadius.circular(8.h),
              ),
              child: GradientText(
                'Post',
                gradient: appTheme.navActiveGradient,
                style: CustomTextStyles.appBarTitle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
