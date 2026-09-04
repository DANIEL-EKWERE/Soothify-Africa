import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/gradient_text.dart';
import '../controller/community_tab_controller.dart';

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
                // Illustration not exported; the design's 346x341 slot is held
                // so the layout below it does not shift when the art lands.
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: appTheme.avatarBacking,
                      borderRadius: BorderRadius.circular(12.h),
                    ),
                  ),
                ),
                SizedBox(height: 24.v),
                Text(
                  'Connect, share, and explore wellness\n'
                  ' topics with others',
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.communityWelcomeBody,
                ),
              ],
            ),
          ),
          SizedBox(height: 80.v),
          _PrimaryButton(
            label: 'Continue',
            enabled: true,
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
          style: CustomTextStyles.subscribeLabel.copyWith(fontSize: 18.fSize),
        ),
      ),
    );
  }
}
