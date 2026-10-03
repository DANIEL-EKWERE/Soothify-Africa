import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/filled_text_field.dart';
import 'controller/corporate_controller.dart';

/// The Corporate enquiry form — Figma "Corporate form" (`259:36101`).
///
/// Reached from "Speak with Corporate Team" on Plans. Measured below the
/// status bar: title 66.5, first caption 113, each box 342x48 eight under its
/// caption, 16 between one field and the next caption, Submit at 801 and 52
/// tall. Content margin 24.
///
/// The frame's own bottom navigation at y=878 is skipped: this is a route
/// pushed over the shell, not a tab.
///
/// The frame titles it "Coperate Plan". That is a typo in the file, in a
/// heading the user reads, so it is spelled correctly here.
class CorporateFormScreen extends GetView<CorporateController> {
  const CorporateFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(24.h, 20.v, 24.h, 32.v),
          children: [
            Row(
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
                    'Corporate Plan',
                    textAlign: TextAlign.center,
                    style: CustomTextStyles.appBarTitle,
                  ),
                ),
                SizedBox(width: 18.h),
              ],
            ),
            SizedBox(height: 26.v),
            for (final field in CorporateField.values) ...[
              Obx(
                () => FilledTextField(
                  label: field.label,
                  labelStyle: CustomTextStyles.corporateLabel,
                  controller: controller.fields[field]!,
                  hintText: field.hint,
                  hasError: controller.missing.contains(field),
                  onChanged: (value) => controller.onChanged(field, value),
                  keyboardType: switch (field) {
                    CorporateField.email => TextInputType.emailAddress,
                    CorporateField.phone => TextInputType.phone,
                    CorporateField.employees => TextInputType.number,
                    _ => TextInputType.text,
                  },
                  textCapitalization: switch (field) {
                    CorporateField.email ||
                    CorporateField.phone =>
                      TextCapitalization.none,
                    _ => TextCapitalization.words,
                  },
                ),
              ),
              SizedBox(height: 16.v),
            ],
            SizedBox(height: 4.v),
            CustomElevatedButton(
              text: 'Submit',
              onPressed: controller.submit,
            ),
          ],
        ),
      ),
    );
  }
}
