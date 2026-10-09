import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/utils/document_picker.dart';
import '../../../../data/models/expert_application.dart';

/// Runs the "Become an Expert" application — Figma `259:59132` (the intro),
/// `259:59145`, `259:59179`, `259:59198` (the three form steps) and
/// `259:59229` (submitted).
///
/// One controller rather than a route per step: the frames share a header and
/// a progress bar and run strictly in order, so a back press should step back
/// through the form rather than unwind a route stack the applicant never
/// chose to build. Same reasoning as [BookingController].
class ExpertApplicationController extends GetxController {
  /// [pickDocument] is injectable so a test can supply a file without a
  /// platform channel; the app uses the system picker.
  ExpertApplicationController({DocumentPicker? pickDocument})
      : _pickDocument = pickDocument ?? pickDocumentFromDevice;

  final DocumentPicker _pickDocument;

  final Rx<ExpertApplicationStep> step = ExpertApplicationStep.profile.obs;

  /// Set once the application has been sent; the form gives way to the
  /// acknowledgement.
  final RxBool submitted = false.obs;

  // Step 1 — who they are.
  //
  /// More than one may apply: the question is "areas of expertise", and a
  /// practitioner can be a licensed therapist *and* a yoga instructor. It
  /// used to be a single choice, so picking a second one dropped the first.
  final RxSet<ExpertField> fields = <ExpertField>{}.obs;
  final name = TextEditingController();
  final experience = TextEditingController();
  final about = TextEditingController();
  final portfolio = TextEditingController();

  // Step 2 — what they can run a session in. The question asks which
  // languages they are fluent in, plural, so more than one can be chosen.
  final RxSet<ExpertLanguage> languages = <ExpertLanguage>{}.obs;

  // Step 3 — proof.
  final licenceNumber = TextEditingController();
  final insurance = TextEditingController();

  /// What has been attached, per slot.
  final RxMap<ExpertDocument, AttachedDocument> attached =
      <ExpertDocument, AttachedDocument>{}.obs;

  /// Redraws the step when a field is typed into, so the button can enable
  /// itself. Text controllers are not observables.
  @override
  void onInit() {
    super.onInit();
    for (final c in [name, experience, about, portfolio, licenceNumber]) {
      c.addListener(_touched);
    }
  }

  final RxInt _revision = 0.obs;

  void _touched() => _revision.value++;

  @override
  void onClose() {
    for (final c in [
      name,
      experience,
      about,
      portfolio,
      licenceNumber,
      insurance,
    ]) {
      c.dispose();
    }
    super.onClose();
  }

  int get stepNumber => step.value.index + 1;

  int get totalSteps => ExpertApplicationStep.values.length;

  /// Whether the step's required answers are all given.
  ///
  /// The frames draw every "Next" in the enabled fill, so they do not say
  /// what is required. The asterisks on the two uploads do, and a question
  /// with no answer cannot advance — that is the rule the rest of the app's
  /// questionnaires already use.
  bool get canAdvance {
    // Touching a text field bumps this, which is what re-evaluates the getter.
    _revision.value;
    return switch (step.value) {
      ExpertApplicationStep.profile => fields.isNotEmpty &&
          name.text.trim().isNotEmpty &&
          experience.text.trim().isNotEmpty,
      ExpertApplicationStep.languages => languages.isNotEmpty,
      // Both uploads carry an asterisk in the frame, so both are required —
      // the only thing on any step that says what is mandatory.
      ExpertApplicationStep.credentials => licenceNumber.text.trim().isNotEmpty &&
          ExpertDocument.values.every(attached.containsKey),
    };
  }

  bool isChosen(ExpertField value) => fields.contains(value);

  void choose(ExpertField value) {
    if (!fields.remove(value)) fields.add(value);
  }

  void toggleLanguage(ExpertLanguage value) {
    if (!languages.remove(value)) languages.add(value);
  }

  bool isSelected(ExpertLanguage value) => languages.contains(value);

  /// Opens the system picker for one slot.
  ///
  /// A cancelled pick leaves whatever was there: backing out of the sheet is
  /// not the same as removing a document already chosen.
  Future<void> attach(ExpertDocument document) async {
    final picked = await _pickDocument();
    if (picked == null) return;
    if (picked.tooLarge) {
      AppFeedback.info(
        '${picked.name} is ${picked.size}. Files must be under '
        '${AttachedDocument.maxBytes ~/ (1024 * 1024)} MB.',
      );
      return;
    }
    attached[document] = picked;
  }

  void removeAttachment(ExpertDocument document) => attached.remove(document);

  /// "Start Application" on the intro.
  void start() => Get.toNamed(AppRoutes.expertApplicationForm);

  void next() {
    if (!canAdvance) return;
    final i = step.value.index;
    if (i < ExpertApplicationStep.values.length - 1) {
      step.value = ExpertApplicationStep.values[i + 1];
      return;
    }
    // Nothing receives an application yet. The acknowledgement is shown
    // because the design draws it, and it promises only a review — it does
    // not claim the application was transmitted.
    submitted.value = true;
  }

  /// Steps back through the form; leaves the route from the first step.
  void back() {
    final i = step.value.index;
    if (i == 0) {
      Get.back();
      return;
    }
    step.value = ExpertApplicationStep.values[i - 1];
  }

  /// "Continue" on the acknowledgement — back to the app, with the form
  /// closed behind it so it cannot be walked back into.
  void done() => Get.until((route) => Get.currentRoute == AppRoutes.shell);
}
