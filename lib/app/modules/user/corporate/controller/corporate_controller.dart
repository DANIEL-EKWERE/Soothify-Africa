import 'package:flutter/widgets.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/repositories/corporate_repository.dart';

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
class CorporateController extends BaseController {
  CorporateController(this._enquiries);

  final CorporateRepository _enquiries;

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

  Future<void> submit() async {
    if (isLoading.value) return;

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

    final sent = await guard(() async {
      await _enquiries.send(
        company: valueOf(CorporateField.company),
        contactName: valueOf(CorporateField.contact),
        email: valueOf(CorporateField.email),
        phone: valueOf(CorporateField.phone),
        employees: valueOf(CorporateField.employees),
        services: valueOf(CorporateField.services),
        notes: valueOf(CorporateField.notes),
      );
      return true;
    }, onError: (error) {
      // A field the server rejected -- a malformed email, most likely.
      // Marked rather than announced, so the form can point at it.
      if (error is ValidationException) {
        missing
          ..clear()
          ..addAll(
            CorporateField.values.where(
              (f) => error.fieldErrors.containsKey(_fieldName(f)),
            ),
          );
      }
    });
    if (sent != true) return;

    Get.toNamed(AppRoutes.corporateSuccess);
  }

  /// What the server calls each field, for marking the ones it refused.
  String _fieldName(CorporateField field) => switch (field) {
        CorporateField.company => 'company',
        CorporateField.contact => 'contact_name',
        CorporateField.email => 'email',
        CorporateField.phone => 'phone',
        CorporateField.employees => 'employees',
        CorporateField.services => 'services',
        CorporateField.notes => 'notes',
      };

  /// "Continue" on the success card returns to the app rather than back into
  /// the form the user has just submitted.
  void done() => Get.until((route) => Get.currentRoute == AppRoutes.shell);
}
