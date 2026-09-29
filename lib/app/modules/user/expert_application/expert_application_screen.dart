import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/expert_application.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/expert_form_fields.dart';
import '../../../widgets/step_progress_bar.dart';
import 'controller/expert_application_controller.dart';

/// The "Become an Expert" application — Figma `259:59145` (who you are),
/// `259:59179` (languages), `259:59198` (credentials) and `259:59229`
/// (submitted).
///
/// Chrome measured off the frames: a 16-square back arrow at (24, 69), the
/// three progress segments at 75.2 (77 wide, 3.6 tall, 10 apart), and the
/// content from 105. Within a step the frames keep one rhythm — 8 between a
/// question and its control, 16 between a control and the next question, and
/// 45 before the button.
class ExpertApplicationScreen extends GetView<ExpertApplicationController> {
  const ExpertApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Obx(
          () => controller.submitted.value
              ? const _Submitted()
              : const _Form(),
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpertApplicationController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 22.v),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.h),
          child: Row(
            children: [
              InkWell(
                onTap: controller.back,
                child: CustomImageView(
                  imagePath: ImageConstant.icArrowLeft,
                  height: 16.h,
                  width: 16.h,
                  color: appTheme.textPrimary,
                ),
              ),
              SizedBox(width: 10.h),
              Expanded(
                child: Obx(
                  () => StepProgressBar(
                    totalSteps: controller.totalSteps,
                    currentStep: controller.stepNumber,
                  ),
                ),
              ),
              SizedBox(width: 65.h),
            ],
          ),
        ),
        Expanded(
          child: Obx(
            () => ListView(
              padding: EdgeInsets.fromLTRB(24.h, 22.v, 24.h, 32.v),
              children: [
                switch (controller.step.value) {
                  ExpertApplicationStep.profile => const _ProfileStep(),
                  ExpertApplicationStep.languages => const _LanguageStep(),
                  ExpertApplicationStep.credentials =>
                    const _CredentialsStep(),
                },
                SizedBox(height: 45.v),
                CustomElevatedButton(
                  text: 'Next',
                  isEnabled: controller.canAdvance,
                  onPressed: controller.next,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileStep extends StatelessWidget {
  const _ProfileStep();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpertApplicationController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('What is your primary area of expertise?',
            style: CustomTextStyles.expertFormLabel),
        SizedBox(height: 16.v),
        Obx(
          () => Column(
            children: [
              for (final field in ExpertField.values) ...[
                ExpertOptionRow(
                  label: field.label,
                  selected: controller.field.value == field,
                  onTap: () => controller.choose(field),
                ),
                if (field != ExpertField.values.last) SizedBox(height: 16.v),
              ],
            ],
          ),
        ),
        SizedBox(height: 45.v),
        ExpertFormField(
          label: 'What is your name?',
          controller: controller.name,
          textCapitalization: TextCapitalization.words,
        ),
        SizedBox(height: 16.v),
        ExpertFormField(
          label: 'What is your years of experience',
          controller: controller.experience,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16.v),
        ExpertFormField(
          label: 'Tell us briefly about yourself?',
          controller: controller.about,
          height: 163,
          maxLines: null,
        ),
        SizedBox(height: 16.v),
        ExpertFormField(
          label: 'Your professional portfolio link',
          controller: controller.portfolio,
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }
}

class _LanguageStep extends StatelessWidget {
  const _LanguageStep();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpertApplicationController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Which languages are you completely fluent in for client sessions?',
          style: CustomTextStyles.expertFormLabel,
        ),
        SizedBox(height: 16.v),
        Obx(
          () => Column(
            children: [
              for (final language in ExpertLanguage.values) ...[
                ExpertOptionRow(
                  label: language.label,
                  selected: controller.isSelected(language),
                  onTap: () => controller.toggleLanguage(language),
                ),
                if (language != ExpertLanguage.values.last)
                  SizedBox(height: 16.v),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CredentialsStep extends StatelessWidget {
  const _CredentialsStep();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpertApplicationController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExpertFormField(
          label: 'License / Certification Number',
          controller: controller.licenceNumber,
        ),
        SizedBox(height: 16.v),
        for (final document in ExpertDocument.values) ...[
          Text(document.prompt, style: CustomTextStyles.expertFormLabel),
          SizedBox(height: 16.v),
          Obx(() {
            final file = controller.attached[document];
            final chip = ExpertUploadChip(
              onTap: () => controller.attach(document),
              attached: file,
              onRemove: () => controller.removeAttachment(document),
            );
            // The empty chip hugs its label; a filled row takes the width.
            return file == null
                ? Align(alignment: Alignment.centerLeft, child: chip)
                : chip;
          }),
          SizedBox(height: 16.v),
        ],
        ExpertFormField(
          label: 'Liability/Practitioner Insurance',
          controller: controller.insurance,
        ),
      ],
    );
  }
}

/// The acknowledgement — `259:59229`.
///
/// Measured: a 343x365 card at 185 with a 16 radius and a `#999999` hairline,
/// a 91.5 green disc 72.8 down inside it, the heading at 196.7 and the note
/// at 231.7, both 277 wide and centred; the action at 695.
class _Submitted extends StatelessWidget {
  const _Submitted();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpertApplicationController>();
    return Column(
      children: [
        SizedBox(height: 141.v),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.h),
          child: Container(
            height: 365.v,
            padding: EdgeInsets.symmetric(horizontal: 33.h),
            decoration: BoxDecoration(
              color: appTheme.surface,
              borderRadius: BorderRadius.circular(16.h),
              border: Border.all(color: appTheme.filterRule),
            ),
            child: Column(
              children: [
                SizedBox(height: 72.8.v),
                Container(
                  width: 91.5.h,
                  height: 91.5.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: appTheme.success,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 54.h,
                    color: appTheme.onPrimary,
                  ),
                ),
                SizedBox(height: 32.4.v),
                Text('Application Submitted!',
                    textAlign: TextAlign.center,
                    style: CustomTextStyles.expertSubmittedTitle),
                SizedBox(height: 16.v),
                Text(
                  'Thank you for applying to join Soothify. Our team is '
                  'reviewing your credentials and will reach out via email '
                  'within 24 to 48 hours once verified.',
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.expertSubmittedBody,
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 25.v),
          child: CustomElevatedButton(
            text: 'Continue',
            onPressed: controller.done,
          ),
        ),
      ],
    );
  }
}
