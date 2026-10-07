import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/settings_entry.dart';
import '../../../widgets/gradient_text.dart';
import 'controller/settings_controller.dart';

/// Settings — Figma "Profile/setting" (135:26963).
///
/// Nine rows at a fixed 44 tall on an 8px rhythm, under the account header,
/// with a gradient-filled version line at the foot.
class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(24.h, 36.v, 24.h, 32.v),
          children: [
            const _Header(),
            SizedBox(height: 25.v),
            const _AccountRow(),
            SizedBox(height: 8.v),
            for (final entry in controller.entries) ...[
              _SettingsRow(entry: entry),
              SizedBox(height: 8.v),
            ],
            SizedBox(height: 16.v),
            const _ExpertModeDoor(),
            SizedBox(height: 16.v),
            Center(
              child: GradientText(
                controller.version,
                gradient: appTheme.authHeaderGradient,
                style: CustomTextStyles.settingsRow,
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
    return Row(
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
            'Settings',
            textAlign: TextAlign.center,
            style: CustomTextStyles.appBarTitle,
          ),
        ),
        SizedBox(width: 16.h),
      ],
    );
  }
}

/// TEMPORARY — a way into the practitioner side of the app.
///
/// The expert dashboard, availability, payouts and session notes all sit
/// behind `/practitioner`, which `resolveStartRoute` opens only when the
/// saved role is already `practitioner`. The one screen that sets that role
/// is `/role`, and nothing navigates to it — so the whole expert app was
/// unreachable from a running build.
///
/// This row stands in until something real grants the role, most likely an
/// approved "Become an Expert" application. **Delete it then.** It is drawn
/// deliberately unlike the designed rows so it is not mistaken for one.
///
/// The way back is the expert's own Profile tab, which offers the role
/// chooser again.
class _ExpertModeDoor extends StatelessWidget {
  const _ExpertModeDoor();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return InkWell(
      onTap: controller.enterExpertMode,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 44.v,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(color: appTheme.accent),
        ),
        child: Text(
          'Open expert mode (temporary)',
          style: CustomTextStyles.settingsRow.copyWith(color: appTheme.accent),
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return SizedBox(
      height: 60.v,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(controller.displayName, style: CustomTextStyles.screenQuestion),
          // The badge said the avatar was editable while nothing happened on
          // tap. It opens the screen that actually changes it.
          GestureDetector(
            onTap: controller.openEditAccount,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 55.h,
              height: 55.h,
              child: Stack(
                children: [
                  ClipOval(
                    child: CustomImageView(
                      imagePath: ImageConstant.imgHomeAvatar,
                      height: 55.h,
                      width: 55.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 19.h,
                      height: 19.h,
                      decoration: BoxDecoration(
                        color: appTheme.soothifyBlue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: appTheme.onPrimary,
                          width: 0.8,
                        ),
                      ),
                      alignment: Alignment.center,
                      // The glyph only — the blue disc and its white ring are
                      // drawn above. The file used to carry its own circle too,
                      // which this tint turned into a white blob filling the
                      // badge, so the pencil was never visible.
                      child: CustomImageView(
                        imagePath: ImageConstant.icEditBadge,
                        height: 11.h,
                        width: 11.h,
                        color: appTheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.entry});

  final SettingsEntry entry;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return InkWell(
      onTap: entry.hasToggle ? null : () => controller.open(entry),
      child: SizedBox(
        height: 44.v,
        child: Row(
          children: [
            CustomImageView(
              imagePath: entry.asset,
              height: 20.h,
              width: 20.h,
              color: appTheme.textPrimary,
            ),
            SizedBox(width: 16.h),
            Expanded(
              child: Text(entry.label, style: CustomTextStyles.settingsRow),
            ),
            if (entry.hasToggle)
              Obx(() {
                // Read through the service so the switch tracks a change made
                // anywhere else, not just its own taps.
                final dark = controller.isDark(context);
                return Transform.scale(
                  scale: 0.7,
                  child: Switch.adaptive(
                    value: !dark,
                    onChanged: (_) => controller.toggleTheme(context),
                    thumbColor: WidgetStatePropertyAll(appTheme.onPrimary),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
