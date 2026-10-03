import 'package:flutter/widgets.dart';

import '../../../../core/app_export.dart';

/// One field on the Corporate form — Figma `259:36101`.
///
/// The frame fills every box with sample text; those are placeholders here,
/// not values, so an untouched form submits empty rather than submitting
/// "Landmark Enterprise" on the user's behalf.
enum CorporateField {
  company('Company Name', 'Landmark Enterprise', required: true),
  contact('Contact Person', 'Mr Felix', required: true),
  email('Email Address', 'chideraokafor@gmail.com', required: true),
  phone('Phone Number', '+234***********', required: true),
  employees('Number of Employees', '15'),
  services('Preferred Services', 'Group Therapy, Mindfulness Exercises'),
  notes('Additional Requirements', 'Thank you for your service');

  const CorporateField(this.label, this.hint, {this.required = false});

  final String label;
  final String hint;

  /// The frame marks nothing as required — it draws one filled state. These
  /// four are the ones without which the enquiry cannot be answered.
  final bool required;
}

/// Backs the Corporate form and its success card — Figma `259:36101` and
/// `259:36093`, reached from "Speak with Corporate Team" on Plans.
class CorporateController extends GetxController {
  final Map<CorporateField, TextEditingController> fields = {
    for (final f in CorporateField.values) f: TextEditingController(),
  };

  /// Which required fields were empty on the last submit. Drives the error
  /// outline; cleared as soon as the field is typed into.
  final RxSet<CorporateField> missing = <CorporateField>{}.obs;

  String valueOf(CorporateField field) => fields[field]!.text.trim();

  void onChanged(CorporateField field, String _) {
    if (missing.contains(field)) missing.remove(field);
  }

  @override
  void onClose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.onClose();
  }

  void submit() {
    final empty = CorporateField.values
        .where((f) => f.required && valueOf(f).isEmpty)
        .toSet();
    missing
      ..clear()
      ..addAll(empty);
    if (empty.isNotEmpty) {
      AppFeedback.error(
        'Add your ${empty.map((f) => f.label.toLowerCase()).join(', ')}.',
      );
      return;
    }
    // Nothing receives this yet. The success card is the design's own next
    // screen, so it is shown; saying the enquiry was sent would be a lie.
    Get.toNamed(AppRoutes.corporateSuccess);
  }

  /// "Continue" on the success card returns to the app rather than back into
  /// the form the user has just submitted.
  void done() => Get.until((route) => Get.currentRoute == AppRoutes.shell);
}
