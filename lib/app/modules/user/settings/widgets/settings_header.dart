import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

/// The header every Settings sub-screen shares — a back arrow at 24 and the
/// title centred, its baseline at 83 in each frame.
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.h, 20.v, 24.h, 0),
      child: Row(
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
              title,
              textAlign: TextAlign.center,
              style: CustomTextStyles.appBarTitle,
            ),
          ),
          SizedBox(width: 18.h),
        ],
      ),
    );
  }
}
