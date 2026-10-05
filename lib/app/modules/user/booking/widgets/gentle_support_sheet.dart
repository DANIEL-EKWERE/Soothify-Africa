import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/custom_elevated_button.dart';

/// "Need gentle support?" — raised from the pill on the call screen.
///
/// A way out of a session that has gone wrong without having to end it first:
/// one of four reasons, then straight to the support team. The reasons are
/// the designer's, bar the fourth — the frame repeats the third verbatim,
/// which is a paste slip, so it reads as the catch-all the set is missing.
class GentleSupportSheet extends StatefulWidget {
  const GentleSupportSheet({super.key, this.onSend});

  /// What to do with the chosen reason. The sheet closes either way.
  final ValueChanged<String>? onSend;

  static const heading = 'We are here to protect your peace';

  static const reasons = [
    'Practitioner suggested meeting outside the app',
    'I felt uncomfortable during our session',
    'I need help with a payment or scheduling issue',
    'Something else I would like to report',
  ];

  static Future<void> show(BuildContext context, {ValueChanged<String>? onSend}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: appTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.h)),
        ),
        builder: (_) => GentleSupportSheet(onSend: onSend),
      );

  @override
  State<GentleSupportSheet> createState() => _GentleSupportSheetState();
}

class _GentleSupportSheetState extends State<GentleSupportSheet> {
  /// The frame shows the first one chosen, so the sheet opens with an answer
  /// rather than a disabled button.
  int _chosen = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.h, 32.v, 24.h, 24.v),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72.h,
              width: 72.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appTheme.policyPanel,
                shape: BoxShape.circle,
              ),
              child: CustomImageView(
                imagePath: ImageConstant.icFlower,
                height: 34.h,
                width: 34.h,
                color: appTheme.soothifyBlue,
              ),
            ),
            SizedBox(height: 24.v),
            Text(
              GentleSupportSheet.heading,
              textAlign: TextAlign.center,
              style: CustomTextStyles.supportHeading,
            ),
            SizedBox(height: 14.v),
            Text(
              'Tell us what happened. Your feedback is private and handled '
              'with care.',
              textAlign: TextAlign.center,
              style: CustomTextStyles.supportBlurb,
            ),
            SizedBox(height: 24.v),
            for (var i = 0; i < GentleSupportSheet.reasons.length; i++) ...[
              _Reason(
                text: GentleSupportSheet.reasons[i],
                chosen: i == _chosen,
                onTap: () => setState(() => _chosen = i),
              ),
              SizedBox(height: 12.v),
            ],
            SizedBox(height: 18.v),
            CustomElevatedButton(
              text: 'Send to Support Team',
              onPressed: () {
                Get.back();
                widget.onSend?.call(GentleSupportSheet.reasons[_chosen]);
              },
            ),
            SizedBox(height: 14.v),
            Text(
              'Your feedback is completely private and handled with care by '
              'our support team.',
              textAlign: TextAlign.center,
              style: CustomTextStyles.supportFootnote,
            ),
          ],
        ),
      ),
    );
  }
}

class _Reason extends StatelessWidget {
  const _Reason({
    required this.text,
    required this.chosen,
    required this.onTap,
  });

  final String text;
  final bool chosen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 18.v),
        decoration: BoxDecoration(
          color: chosen ? appTheme.surface : appTheme.fieldFill,
          borderRadius: BorderRadius.circular(10.h),
          border: Border.all(
            color: chosen ? appTheme.soothifyBlue : appTheme.fieldRim,
          ),
        ),
        child: Text(text, maxLines: 1, style: CustomTextStyles.supportReason),
      ),
    );
  }
}
