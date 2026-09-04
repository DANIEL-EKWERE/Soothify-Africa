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
          Text(
            controller.displayName,
            style: CustomTextStyles.screenQuestion,
          ),
          SizedBox(
            width: 55.h,
            height: 55.h,
            child: Stack(
              children: [
                Container(
                  width: 55.h,
                  height: 55.h,
                  decoration: BoxDecoration(
                    color: appTheme.avatarBacking,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  // Artwork not exported; the backing circle is the design's.
                  child: Icon(
                    Icons.person_outline,
                    size: 28.h,
                    color: appTheme.textPrimary,
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
                      border: Border.all(color: appTheme.onPrimary, width: 0.8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.edit,
                      size: 9.h,
                      color: appTheme.onPrimary,
                    ),
                  ),
                ),
              ],
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
