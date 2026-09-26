import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

/// The header every pushed expert screen carries — a back chevron at 24 and
/// the title centred, both on the row at y=70.
class ExpertHeader extends StatelessWidget {
  const ExpertHeader({super.key, required this.title, this.onBack});

  final String title;

  /// Defaults to popping the route.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 24.h),
            child: InkWell(
              onTap: onBack ?? Get.back,
              child: CustomImageView(
                imagePath: ImageConstant.icBack,
                height: 18.h,
                width: 18.h,
                color: appTheme.textPrimary,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 56.h),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: CustomTextStyles.appBarTitle,
          ),
        ),
      ],
    );
  }
}
