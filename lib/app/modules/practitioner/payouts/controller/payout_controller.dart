import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/expert_earnings.dart';
import '../../../../data/models/payout_method.dart';
import '../../dashboard/controller/expert_dashboard_controller.dart';

/// Backs withdrawing, choosing a destination, and the payout history —
/// Figma `259:59559`, `259:59463` and `259:59782`.
///
/// One controller for the three: they are one errand, and the amount chosen
/// on the first has to survive into the second.
class PayoutController extends GetxController {
  PayoutController(this._dashboard);

  final ExpertDashboardController _dashboard;

  final amount = TextEditingController();

  /// The frame opens with Bank Transfer outlined in blue — the only selected
  /// state it draws.
  final Rx<PayoutMethod> method = PayoutMethod.bankTransfer.obs;

  ExpertEarnings? get earnings => _dashboard.earnings.value;

  List<Payout> get payouts => earnings?.payouts ?? const [];

  int get available => earnings?.available ?? 0;

  /// Set once the figure has been typed into, so a late-arriving balance
  /// does not overwrite what was entered.
  bool _edited = false;

  @override
  void onInit() {
    super.onInit();
    // The frame prints the whole balance as the starting figure, which is
    // also the most common withdrawal.
    //
    // Seeded reactively, not once: this screen can be built before the
    // dashboard's load has returned, and reading the balance then gives 0.
    _seed();
    ever(_dashboard.earnings, (_) => _seed());
  }

  void _seed() {
    if (_edited || available == 0) return;
    amount.text = '$available';
  }

  /// Called by the field, so a later balance stops overwriting the figure.
  void markEdited() => _edited = true;

  @override
  void onClose() {
    amount.dispose();
    super.onClose();
  }

  int get requested => int.tryParse(amount.text.replaceAll(',', '').trim()) ?? 0;

  /// Nothing in the frames says what happens when more is asked for than is
  /// there, but a payout screen must not let it through.
  ///
  /// [available] is read into a local first, deliberately: written as
  /// `requested > 0 && requested <= available` it short-circuits on an empty
  /// field, never touches the observable, and the Obx watching this getter
  /// has nothing to rebuild on.
  bool get canProceed {
    final balance = available;
    final want = requested;
    return want > 0 && want <= balance;
  }

  void choose(PayoutMethod value) => method.value = value;

  void openMethod() => Get.toNamed(AppRoutes.expertPayoutMethod);

  void openHistory() => Get.toNamed(AppRoutes.expertPayouts);

  /// No payment provider is wired on this side either. The frame's own
  /// footnote says Paystack processes these; until it does, saying so beats
  /// claiming money moved.
  void proceed() => AppFeedback.info(
        'Paying out through ${method.value.label} is not built yet.',
      );
}
