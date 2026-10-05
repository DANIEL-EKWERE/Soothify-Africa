import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/confetti_overlay.dart';
import '../../../widgets/gradient_text.dart';
import '../../../widgets/match_progress_bar.dart';
import 'controller/booking_controller.dart';
import 'widgets/gentle_support_sheet.dart';
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
            // The frames title this flow "Schedule", not the tile's words —
            // `Matching pilates instructor` (259:58806) and "Book a licensed
            // expert screen" (259:31488) both do.
            'Schedule',
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

/// The session itself — Figma's two call frames, redrawn 2026-10-05.
///
/// Voice and video share everything but their backdrop: voice puts the
/// expert's portrait, name and the running time on the app's own background;
/// video fills the screen with their camera and insets the user's own. Both
/// carry the gentle-support pill at the top left and the same three controls.
class _CallStage extends StatelessWidget {
  const _CallStage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();
    // Its own Obx: this widget is built outside the one that watches the
    // stage, so reading `mode` there would not register.
    return Obx(() => controller.mode.value == CallMode.video
        ? const _VideoCall()
        : const _VoiceCall());
  }
}

class _VoiceCall extends StatelessWidget {
  const _VoiceCall();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 16.v),
        const Padding(
          padding: EdgeInsets.only(left: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GentleSupportPill(),
          ),
        ),
        SizedBox(height: 32.v),
        Center(
          child: ClipOval(
            child: CustomImageView(
              imagePath: ImageConstant.imgCoachCallAvatar,
              height: 100.h,
              width: 100.h,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 22.v),
        Text(
          controller.coachName,
          textAlign: TextAlign.center,
          style: CustomTextStyles.callName,
        ),
        SizedBox(height: 10.v),
        Text(
          '0:30',
          textAlign: TextAlign.center,
          style: CustomTextStyles.callClock,
        ),
        SizedBox(height: 92.v),
        const _CallControls(),
        const Spacer(),
      ],
    );
  }
}

/// The video call — the expert full bleed, the user inset above the controls.
class _VideoCall extends StatelessWidget {
  const _VideoCall();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomImageView(
          imagePath: ImageConstant.imgCoachVideo,
          fit: BoxFit.cover,
        ),
        Positioned(
          left: 24.h,
          top: 16.v,
          child: const GentleSupportPill(onVideo: true),
        ),
        // The user's own camera, sat just above the controls on the right.
        Positioned(
          right: 24.h,
          bottom: 104.v,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.h),
            child: CustomImageView(
              imagePath: ImageConstant.imgCoachPeers.first,
              height: 202.v,
              width: 152.h,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 24.v,
          child: const _CallControls(onVideo: true),
        ),
      ],
    );
  }
}

/// Mic, camera and hang up.
class _CallControls extends StatelessWidget {
  const _CallControls({this.onVideo = false});

  /// Over the video the two toggles are filled white; on the voice call they
  /// are outlined, because there is no picture for them to stand out against.
  final bool onVideo;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CallButton(
          icon: Icons.mic_none,
          onTap: () {},
          fill: onVideo ? appTheme.surface : appTheme.transparent,
          rim: onVideo ? null : appTheme.callControlRim,
        ),
        SizedBox(width: 30.h),
        _CallButton(
          icon: Icons.videocam_outlined,
          onTap: () {},
          fill: onVideo ? appTheme.surface : appTheme.transparent,
          rim: onVideo ? null : appTheme.callControlRim,
        ),
        SizedBox(width: 30.h),
        _CallButton(
          icon: Icons.call_end,
          onTap: controller.endCall,
          fill: appTheme.callEndFill,
          tint: appTheme.onPrimary,
        ),
      ],
    );
  }
}

/// "Need gentle support?" — a way to reach the support team mid-session.
class GentleSupportPill extends StatelessWidget {
  const GentleSupportPill({super.key, this.onVideo = false});

  /// Over the video it needs a backdrop of its own; on the voice call the
  /// screen is already pale enough for the design's tint.
  final bool onVideo;

  static const label = 'Need gentle support?';

  @override
  Widget build(BuildContext context) {
    final ink = onVideo ? appTheme.onPrimary : appTheme.soothifyBlue;
    return InkWell(
      onTap: () => GentleSupportSheet.show(context),
      borderRadius: BorderRadius.circular(100.h),
      child: Container(
        height: 44.v,
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        decoration: BoxDecoration(
          color: onVideo
              ? appTheme.textPrimary.withValues(alpha: 0.45)
              : appTheme.policyPanel,
          borderRadius: BorderRadius.circular(100.h),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomImageView(
              imagePath: ImageConstant.icFlower,
              height: 22.h,
              width: 22.h,
              color: ink,
            ),
            SizedBox(width: 10.h),
            Text(label, style: CustomTextStyles.supportPill.copyWith(color: ink)),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.icon,
    required this.onTap,
    required this.fill,
    this.tint,
    this.rim,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color fill;
  final Color? tint;
  final Color? rim;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 68.h,
        height: 68.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          border: rim == null ? null : Border.all(color: rim!),
        ),
        // Call controls were not exported; Material stands in for these three.
        child: Icon(icon, size: 32.h, color: tint ?? appTheme.textPrimary),
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

class _FeedbackStage extends StatefulWidget {
  const _FeedbackStage();

  @override
  State<_FeedbackStage> createState() => _FeedbackStageState();
}

class _FeedbackStageState extends State<_FeedbackStage> {
  final FocusNode _node = FocusNode();

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _node.removeListener(_onFocusChanged);
    _node.dispose();
    super.dispose();
  }

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
        // The focus ring belongs to this box, not to the field inside it.
        //
        // The app's `inputDecorationTheme` carries a focused outline, and
        // `border: InputBorder.none` does not switch that off — the decorator
        // falls back to the theme for the focused state alone. So on focus a
        // second blue rounded rectangle was drawn *inside* this one, inset by
        // the padding and short of the corners. Every border is off now and
        // the box itself answers to focus.
        Container(
          height: 161.v,
          padding: EdgeInsets.fromLTRB(12.h, 8.v, 12.h, 8.v),
          decoration: BoxDecoration(
            color: appTheme.fieldFill,
            borderRadius: BorderRadius.circular(8.h),
            border: Border.all(
              color: _node.hasFocus
                  ? appTheme.soothifyBlue
                  : appTheme.navInactive,
            ),
          ),
          child: TextField(
            controller: controller.feedback,
            focusNode: _node,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: CustomTextStyles.topicChip,
            cursorColor: appTheme.soothifyBlue,
            decoration: InputDecoration(
              hintText: 'Write......',
              hintStyle: CustomTextStyles.pillLabel
                  .copyWith(color: appTheme.navInactive),
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
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
