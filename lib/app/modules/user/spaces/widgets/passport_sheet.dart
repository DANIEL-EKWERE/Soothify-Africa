import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/custom_elevated_button.dart';
import '../../../../widgets/gradient_text.dart';

/// "Step into the broader sanctuary" — the sheet behind the Passport teaser
/// on the studio profile (`282:25364`).
///
/// **Its copy was given by the designer, not read from the file.** The sheet
/// is not a frame on page `124:2` — the index is unchanged at 871 frames and
/// nothing cached carries this wording — so it lives on another page or
/// nested inside a frame that has not been pulled whole. The words below are
/// exact; the layout is this app's, following [ScheduleSheet]'s conventions,
/// and should be re-measured when the frame turns up.
class PassportSheet extends StatelessWidget {
  const PassportSheet({super.key});

  static const String heading = 'Step into the broader sanctuary';

  static const List<String> body = [
    'We are putting together the finest physical spaces, boutique studios, '
        'and restorative sanctuaries across Abuja and Lagos for your journey.',
    'Be the first to experience physical movement and spa passes the moment '
        'our doors open.',
  ];

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        backgroundColor: appTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.h)),
        ),
        builder: (_) => const PassportSheet(),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.h, 20.v, 24.h, 32.v),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              height: 4.v,
              width: 36.h,
              decoration: BoxDecoration(
                color: appTheme.sheetHandle,
                borderRadius: BorderRadius.circular(4.h),
              ),
            ),
          ),
          SizedBox(height: 24.v),
          Center(
            child: Container(
              height: 72.7.h,
              width: 72.7.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appTheme.careCrest,
                shape: BoxShape.circle,
              ),
              child: CustomImageView(
                imagePath: ImageConstant.icFlower,
                height: 50.9.h,
                width: 50.9.h,
              ),
            ),
          ),
          SizedBox(height: 24.v),
          GradientText(
            heading,
            gradient: appTheme.authHeaderGradient,
            textAlign: TextAlign.center,
            style: CustomTextStyles.kycQuestion,
          ),
          SizedBox(height: 16.v),
          for (final paragraph in body) ...[
            Text(
              paragraph,
              textAlign: TextAlign.center,
              style: CustomTextStyles.studioAbout,
            ),
            SizedBox(height: 16.v),
          ],
          SizedBox(height: 8.v),
          CustomElevatedButton(
            text: 'Notify me',
            onPressed: () {
              Get.back();
              AppFeedback.info(
                'You’re on the list — we’ll tell you the moment passes open.',
              );
            },
          ),
        ],
      ),
    );
  }
}
