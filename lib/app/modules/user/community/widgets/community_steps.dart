import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/gradient_text.dart';
import '../controller/community_tab_controller.dart';

/// What the Community tab shows while the forum is not being built — the
/// designer's screenshot of 2026-10-05.
///
/// It replaces the welcome → username → topics walk entirely. Nothing below
/// was deleted: [CommunityWelcomeStep] and the rest still exist, and the tab
/// can be pointed back at them when the forum is picked up again.
///
/// The illustration is a stand-in. The frame is not on page 124:2, so the
/// artwork could not be exported; `community/welcome.png` is the nearest
/// thing the app already ships and wants replacing once the real one lands.
class CommunityComingSoon extends StatelessWidget {
  const CommunityComingSoon({super.key});

  static const String heading = 'Your safe space is coming soon';

  static const String body =
      'We’re building a mindful space for you to connect, share your '
      'practice, and grow with other members. We want to get it just right.';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunityTabController>();
    return Padding(
      padding: EdgeInsets.fromLTRB(24.h, 40.v, 24.h, 24.v),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            heading,
            textAlign: TextAlign.center,
            style: CustomTextStyles.comingSoonHeading,
          ),
          SizedBox(height: 28.v),
          Expanded(
            child: Image.asset(
              ImageConstant.imgCommunityWelcome,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 28.v),
          Text(
            body,
            textAlign: TextAlign.center,
            style: CustomTextStyles.comingSoonBody,
          ),
          SizedBox(height: 28.v),
          _PrimaryButton(
            label: 'Explore Classes',
            enabled: true,
            onTap: controller.exploreClasses,
          ),
          SizedBox(height: 8.v),
        ],
      ),
    );
  }
}

/// The community's one-time welcome — Figma 135:5758.
class CommunityWelcomeStep extends StatelessWidget {
  const CommunityWelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunityTabController>();
    return Padding(
      padding: EdgeInsets.fromLTRB(22.h, 78.v, 22.h, 19.v),
      child: Column(
        children: [
          Text(
            'Welcome to Soothify Community',
            textAlign: TextAlign.center,
            style: CustomTextStyles.communityWelcomeTitle,
          ),
          SizedBox(height: 48.v),
          Expanded(
            child: Column(
              children: [
                // Exported from the frame itself (node 135:5765). It is a 3D
                // render, not the flat illustration the intro carousel uses —
                // the two are not interchangeable.
                Expanded(
                  child: Image.asset(
                    ImageConstant.imgCommunityWelcome,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 24.v),
                // The Figma string carries a newline after "wellness", but
                // the bundled Nunito Sans renders a few pixels wider than the
                // design's instance, so honouring it wrapped the first line
                // too and gave three ragged lines. Left to wrap naturally it
                // lands on the design's two.
                Text(
                  'Connect, share, and explore wellness topics with others',
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.communityWelcomeBody,
                ),
              ],
            ),
          ),
          SizedBox(height: 80.v),
          // The community is not being built yet, so the welcome does not
          // lead anywhere: the button says so and stays disabled rather than
          // opening a username step and a forum that are not ready.
          //
          // Everything behind it still exists; restoring the flow is a matter
          // of putting `dismissWelcome` back here.
          _PrimaryButton(
            label: 'Coming soon',
            enabled: false,
            onTap: controller.dismissWelcome,
          ),
        ],
      ),
    );
  }
}

/// Choosing a forum handle — Figma 135:5768.
class CommunityUsernameStep extends StatelessWidget {
  const CommunityUsernameStep({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunityTabController>();
    return Padding(
      padding: EdgeInsets.fromLTRB(24.h, 58.v, 24.h, 19.v),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GradientText(
            'Create a Username',
            gradient: appTheme.authHeaderGradient,
            style: CustomTextStyles.communityHeading,
          ),
          SizedBox(height: 7.v),
          GradientText(
            'Let’s get started',
            gradient: appTheme.authHeaderGradient,
            style: CustomTextStyles.communityBody,
          ),
          SizedBox(height: 40.v),
          Text('Username', style: CustomTextStyles.formLabel),
          SizedBox(height: 8.v),
          SizedBox(
            height: 48.v,
            child: TextField(
              onChanged: (v) => controller.usernameDraft.value = v,
              style: CustomTextStyles.topicChip,
              decoration: InputDecoration(
                hintText: 'Chidera Dera',
                hintStyle: CustomTextStyles.topicChip,
                filled: true,
                fillColor: appTheme.surface,
                contentPadding: EdgeInsets.symmetric(horizontal: 13.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.h),
                  borderSide: BorderSide(color: appTheme.soothifyBlue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.h),
                  borderSide: BorderSide(color: appTheme.soothifyBlue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.h),
                  borderSide: BorderSide(color: appTheme.soothifyBlue),
                ),
              ),
            ),
          ),
          const Spacer(),
          Obx(() => _PrimaryButton(
                label: 'Create Username',
                // The design shows no disabled state here; the button is
                // gated anyway so a blank or one-character handle cannot be
                // committed to the forum.
                enabled: controller.canCreateUsername,
                onTap: controller.createUsername,
              )),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
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
          style: CustomTextStyles.subscribeLabel,
        ),
      ),
    );
  }
}
