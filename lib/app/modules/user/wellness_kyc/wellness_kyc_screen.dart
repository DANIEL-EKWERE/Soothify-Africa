import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/gradient_text.dart';
import '../../../widgets/match_progress_bar.dart';
import 'controller/wellness_kyc_controller.dart';

/// A section's pre-booking questionnaire — Figma `Pilates kyc` (259:38525
/// for the intro, 259:38083 onward for the questions) and
/// `Scheduling Kyc/Yoga` (259:38802).
///
/// The intro and the questions are one route: the design gives the intro no
/// control of its own, so it is a tap-anywhere interstitial rather than a
/// screen with a hidden button.
///
/// Measured: on a question, the heading at 97 (Nunito Sans 700 20 on the
/// `#2F6FED -> #274889` run), its hint 8 beneath, then 48 to a two-column
/// grid of 160x90 tiles 20 apart at a 110 pitch, and 135 from the last row to
/// the action. The intro puts its heading at 197 and its paragraph at 246.
///
/// **The question frames carry no header and no progress bar** — the intro's
/// chevron is the only one drawn. A bare back chevron is kept on the
/// questions all the same: six steps with no way back is a trap on a platform
/// without a hardware back button.
class WellnessKycScreen extends GetView<WellnessKycController> {
  const WellnessKycScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Obx(
          () => Padding(
            padding: EdgeInsets.fromLTRB(24.h, 17.v, 24.h, 24.v),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The frames title only the intro.
                _Header(title: controller.onIntro ? 'Schedule' : ''),
                Expanded(
                  child: controller.onIntro
                      ? const _Intro()
                      // Keyed by step, and not const: a const _Question has
                      // no fields, so every step produced the *same*
                      // canonicalised widget and Flutter skipped the rebuild
                      // — question one repeated forever.
                      : _Question(step: controller.index.value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WellnessKycController>();
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
            title,
            textAlign: TextAlign.center,
            style: CustomTextStyles.appBarTitle,
          ),
        ),
        SizedBox(width: 18.h),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WellnessKycController>();
    return GestureDetector(
      onTap: controller.begin,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 116.v),
          if (controller.track.heading.isNotEmpty) ...[
            GradientText(
              controller.track.heading,
              gradient: appTheme.authHeaderGradient,
              style: CustomTextStyles.kycQuestion,
            ),
            SizedBox(height: 23.v),
          ],
          Text(controller.track.intro, style: CustomTextStyles.kycIntroBody),
          // 24 below the paragraph on both intro frames — the same bar the
          // matching screen draws. It is what tells the user the screen is
          // working, and why the frame needs no button.
          SizedBox(height: 24.v),
          Obx(() => MatchProgressBar(value: controller.introProgress.value)),
          // No "Tap anywhere to continue" beneath it: the frames never drew
          // one, and the bar already says the screen is moving on by itself.
          // The tap still works, it is just no longer advertised.
        ],
      ),
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({required this.step});

  /// The index this question is showing. Held as a field so the widget
  /// differs between steps and the subtree actually rebuilds.
  final int step;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WellnessKycController>();
    final question = controller.track.steps[step];
    // Reading the answers *here* is what subscribes this subtree to them. The
    // screen's outer Obx only reads the step index, so choosing an option
    // rebuilt nothing: no tile ever looked selected and Next stayed disabled.
    return Obx(() {
      controller.answers.length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 9.v),
          GradientText(
            question.question,
            gradient: appTheme.authHeaderGradient,
            style: CustomTextStyles.kycQuestion,
          ),
          // Solid, not on the run: the frame gradient-fills the question and
          // leaves this line in plain #323233.
          if (question.multiSelect) ...[
            SizedBox(height: 8.v),
            Text(controller.track.multiHint,
                style: CustomTextStyles.kycIntroBody),
          ],
          SizedBox(height: 48.v),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 20.h,
                runSpacing: 20.v,
                children: [
                  for (final option in question.options)
                    _OptionTile(
                      label: option,
                      selected: controller.isSelected(option),
                      onTap: () => controller.choose(option),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.v),
          _NextButton(
            label: controller.actionLabel,
            enabled: controller.canAdvance,
            onTap: controller.next,
          ),
        ],
      );
    });
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.h),
      child: Container(
        width: 160.h,
        height: 90.v,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 10.h),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(4.h),
          // The frame draws no outline on an unselected tile; selection is
          // shown with the brand hairline, as on the Community chips.
          border: selected
              ? Border.all(color: appTheme.soothifyBlue)
              : Border.all(color: appTheme.transparent),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: CustomTextStyles.topicChip,
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 52.v,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? appTheme.actionFill : appTheme.actionFillDisabled,
          borderRadius: BorderRadius.circular(8.h),
        ),
        child: Text(
          label,
          style: CustomTextStyles.subscribeLabel.copyWith(fontSize: 18.fSize),
        ),
      ),
    );
  }
}
