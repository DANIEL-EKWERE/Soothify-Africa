import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_ghost_button.dart';
import 'controller/settings_controller.dart';
import 'widgets/settings_header.dart';

/// "User Profile" — redrawn by the designer on 2026-10-07, with the
/// photo-source sheet it raises.
///
/// This is where the avatar is changed, so Settings' own avatar opens it.
///
/// Measured below the status bar: the avatar 154 across at 136.5 on a pale
/// blue disc, a 36 "+" straddling its bottom edge, the name at 317 with a
/// pencil at its top right, and the button at 517.5, 52 tall.
class UserProfileScreen extends GetView<SettingsController> {
  const UserProfileScreen({super.key});

  /// The sheet the "+" raises. Static so the avatar can reach it.
  static Future<void> showPhotoSources(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: appTheme.transparent,
      builder: (_) => Container(
        margin: EdgeInsets.fromLTRB(73.h, 0, 73.h, 24.v),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Two sources, not the three the old frame drew: the Facebook
            // upload is gone, and the gallery is the highlighted one.
            for (final (label, highlighted) in const [
              ('Take a photo', false),
              ('Upload from gallery', true),
            ])
              InkWell(
                onTap: () {
                  Get.back();
                  controller.pickPhoto(label);
                },
                child: Container(
                  height: 43.v,
                  width: double.infinity,
                  alignment: Alignment.center,
                  color:
                      highlighted ? appTheme.background : appTheme.transparent,
                  child: Text(
                    label,
                    style: highlighted
                        ? CustomTextStyles.photoSourceSelected
                        : CustomTextStyles.photoSource,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SettingsHeader(title: 'User Profile'),
            SizedBox(height: 52.v),
            const Center(child: _Avatar()),
            SizedBox(height: 27.v),
            const _Name(),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: CustomGhostButton(
                text: 'Save Changes',
                onPressed: controller.saveProfile,
              ),
            ),
            SizedBox(height: 56.v),
          ],
        ),
      ),
    );
  }
}

/// The portrait, on the frame's pale blue disc, with the "+" that changes it.
///
/// The badge straddles the disc's bottom edge rather than sitting inside its
/// lower right, which is where the previous frame put a pencil.
class _Avatar extends StatelessWidget {
  const _Avatar();

  static const double size = 154;
  static const double badge = 36;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (size + badge / 2).h,
      width: size.h,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: size.h,
            width: size.h,
            decoration: BoxDecoration(
              // Behind the illustration rather than instead of it: the PNG
              // carries this same disc, so this only shows while it decodes.
              color: appTheme.avatarWash,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: CustomImageView(
              imagePath: ImageConstant.imgAvatarMemoji,
              height: size.h,
              width: size.h,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            child: InkWell(
              onTap: () => UserProfileScreen.showPhotoSources(context),
              customBorder: const CircleBorder(),
              child: Container(
                height: badge.h,
                width: badge.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appTheme.soothifyBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add,
                    size: 22.h, color: appTheme.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The name, with the pencil the frame hangs off its top right.
class _Name extends StatelessWidget {
  const _Name();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(controller.fullName, style: CustomTextStyles.profileName),
        SizedBox(width: 6.h),
        Padding(
          padding: EdgeInsets.only(top: 2.v),
          child: CustomImageView(
            imagePath: ImageConstant.icEditBadge,
            height: 16.h,
            width: 16.h,
            color: appTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
