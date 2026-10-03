import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/custom_elevated_button.dart';
import '../../../../widgets/filled_text_field.dart';
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
class PassportSheet extends StatefulWidget {
  const PassportSheet({super.key});

  static const String heading = 'Step into the broader sanctuary';

  static const List<String> body = [
    'We are putting together the finest physical spaces, boutique studios, '
        'and restorative sanctuaries across Abuja and Lagos for your journey.',
    'Be the first to experience physical movement and spa passes the moment '
        'our doors open.',
  ];

  static const String action = 'Reserve my place on the waitlist';

  /// Deliberately loose. The only thing worth rejecting here is an address
  /// that cannot be one — a stricter pattern turns away valid addresses, and
  /// the cost of a typo reaching a list that does not exist yet is nothing.
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s.]+\.[^@\s]+$');

  static bool isValidEmail(String value) => _email.hasMatch(value.trim());

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    backgroundColor: appTheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.h)),
    ),
    // The keyboard must not sit on top of the field.
    isScrollControlled: true,
    builder: (_) => const PassportSheet(),
  );

  @override
  State<PassportSheet> createState() => _PassportSheetState();
}

class _PassportSheetState extends State<PassportSheet> {
  final TextEditingController _email = TextEditingController();

  bool _invalid = false;

  @override
  void initState() {
    super.initState();
    // Someone who already left an address sees it back rather than being
    // asked a second time.
    _email.text = PrefUtils().passportWaitlistEmail() ?? '';
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _reserve() async {
    final address = _email.text.trim();
    if (!PassportSheet.isValidEmail(address)) {
      setState(() => _invalid = true);
      return;
    }
    await PrefUtils().setPassportWaitlistEmail(address);
    if (!mounted) return;
    Get.back();
    // Says what actually happened. Nothing is sent anywhere — there is no
    // waitlist endpoint — so it does not promise that anyone has been told.
    AppFeedback.info('Saved. We\u2019ll use $address when passes open.');
  }

  @override
  Widget build(BuildContext context) {
    // The field needs a Material ancestor. `showModalBottomSheet` supplies
    // one, but a transparent Material here means the sheet also stands on its
    // own — mounted directly, as a test or a preview does.
    return Material(
      color: appTheme.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24.h,
          20.v,
          24.h,
          32.v + MediaQuery.viewInsetsOf(context).bottom,
        ),
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
              PassportSheet.heading,
              gradient: appTheme.authHeaderGradient,
              textAlign: TextAlign.center,
              style: CustomTextStyles.kycQuestion,
            ),
            SizedBox(height: 16.v),
            for (final paragraph in PassportSheet.body) ...[
              Text(
                paragraph,
                textAlign: TextAlign.center,
                style: CustomTextStyles.studioAbout,
              ),
              SizedBox(height: 16.v),
            ],
            SizedBox(height: 8.v),
            FilledTextField(
              label: 'Email address',
              labelStyle: CustomTextStyles.corporateLabel,
              controller: _email,
              hintText: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              hasError: _invalid,
              onChanged: (_) {
                if (_invalid) setState(() => _invalid = false);
              },
            ),
            if (_invalid) ...[
              SizedBox(height: 6.v),
              Text(
                'Enter an email address we can reach you on.',
                style: CustomTextStyles.inlineError,
              ),
            ],
            SizedBox(height: 20.v),
            CustomElevatedButton(
              text: PassportSheet.action,
              onPressed: _reserve,
            ),
          ],
        ),
      ),
    );
  }
}
