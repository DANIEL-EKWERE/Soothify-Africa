import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_ghost_button.dart';
import 'controller/settings_controller.dart';
import 'widgets/settings_header.dart';

/// "User Profile" — Figma `259:37551`, with the photo-source sheet from
/// `259:37567`, reached from Account Settings -> Edit Account Details.
///
/// Measured below the status bar: the avatar 154 across at 178, its edit
/// badge 38 at the lower right, the name at 367 in Nunito Sans Bold 20, and
/// the ghost button at 559.
class UserProfileScreen extends GetView<SettingsController> {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SettingsHeader(title: 'User Profile'),
            SizedBox(height: 71.v),
            Center(
              child: SizedBox(
                height: 154.h,
                width: 154.h,
                child: Stack(
                  children: [
                    ClipOval(
                      child: CustomImageView(
                        imagePath: ImageConstant.imgAvatarFemale,
                        height: 154.h,
                        width: 154.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 4.h,
                      bottom: 4.h,
                      child: InkWell(
                        onTap: () => _showPhotoSources(context),
                        customBorder: const CircleBorder(),
                        child: Container(
                          height: 38.h,
                          width: 38.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: appTheme.soothifyBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: appTheme.onPrimary,
                              width: 2,
                            ),
                          ),
                          child: CustomImageView(
                            imagePath: ImageConstant.icEditBadge,
                            height: 20.h,
                            width: 20.h,
                            color: appTheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 35.v),
            Text(
              controller.fullName,
              textAlign: TextAlign.center,
              style: CustomTextStyles.profileName,
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 23.h),
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

  /// The sheet `259:37567` draws over the avatar — three sources, the middle
  /// one highlighted.
  Future<void> _showPhotoSources(BuildContext context) =>
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: appTheme.transparent,
        builder: (_) => Container(
          margin: EdgeInsets.fromLTRB(73.h, 0, 73.h, 24.v),
          decoration: BoxDecoration(
            color: appTheme.surface,
            borderRadius: BorderRadius.circular(8.h),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (label, highlighted) in const [
                ('Take a photo', false),
                ('Upload from gallery', true),
                ('Upload from facebook', false),
              ])
                InkWell(
                  onTap: () {
                    Get.back();
                    controller.pickPhoto(label);
                  },
                  child: Container(
                    height: 38.v,
                    width: double.infinity,
                    alignment: Alignment.center,
                    color: highlighted
                        ? appTheme.background
                        : appTheme.transparent,
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
