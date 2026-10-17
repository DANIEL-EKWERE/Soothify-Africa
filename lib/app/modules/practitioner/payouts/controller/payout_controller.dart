import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/bank_destination.dart';
import '../../../../data/models/bank_option.dart';
import '../../../../data/models/expert_earnings.dart';
import '../../../../data/models/payout_method.dart';
import '../../dashboard/controller/expert_dashboard_controller.dart';
import '../expert_payout_outcome_screen.dart';

/// Backs withdrawing, choosing a destination, and the payout history —
/// Figma `259:59559`, `259:59463` and `259:59782`.
///
/// One controller for the three: they are one errand, and the amount chosen
/// on the first has to survive into the second.
class PayoutController extends GetxController {
  PayoutController(this._dashboard);

  final ExpertDashboardController _dashboard;

  final amount = TextEditingController();

  /// The bank destination form. Three fields, because a transfer needs all
  /// three and a half-filled one is a payment that never arrives.
  final accountNumber = TextEditingController();
  final accountName = TextEditingController();
  final RxString bank = ''.obs;

  /// Nudged on every keystroke so [canSaveBank] has something to rebuild on:
  /// a TextEditingController is not observable.
  final RxInt _bankEdits = 0.obs;

  /// The banks the picker offers, from the provider.
  ///
  /// Read rather than written into the app: a list of Nigerian banks goes
  /// out of date, and each one's code is what the account lookup needs — a
  /// name alone cannot be resolved, so a typed bank cannot be paid.
  final RxList<BankOption> bankOptions = <BankOption>[].obs;

  List<String> get banks => bankOptions.map((b) => b.name).toList();

  String get _chosenBankCode =>
      bankOptions.firstWhereOrNull((b) => b.name == bank.value)?.code ?? '';

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
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    final found = await _dashboard.banks();
    if (found.isNotEmpty) bankOptions.assignAll(found);
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
    accountNumber.dispose();
    accountName.dispose();
    super.onClose();
  }

  void chooseBank(String value) {
    bank.value = value;
    touchBank();
  }

  void touchBank() => _bankEdits.value++;

  bool get canSaveBank {
    _bankEdits.value;
    return bank.value.isNotEmpty &&
        // Ten digits is a Nigerian account number; a bank with no code
        // cannot be resolved, so it cannot be saved either.
        accountNumber.text.trim().length >= 10 &&
        _chosenBankCode.isNotEmpty;
  }

  /// Which account a withdrawal is heading to — the index of the outlined
  /// tile under "Destination of funds".
  final RxInt chosenDestination = 0.obs;

  /// The accounts on file. Owned by the dashboard controller, which outlives
  /// these routes.
  List<BankDestination> get destinations => _dashboard.destinations;

  bool get hasDestination => destinations.isNotEmpty;

  void chooseDestination(int index) => chosenDestination.value = index;

  /// The row the Earnings card prints beside "Payout method".
  String get savedDestination =>
      hasDestination ? destinations.first.masked : 'Not set';

  /// Which account the form is replacing, or null when it is adding one.
  ///
  /// Replacing is adding, at the provider: there is no way to edit an
  /// account there, and a new default demotes the old one. This is kept so
  /// the form knows which trip it is on and can clear itself afterwards.
  // ignore: unused_field  -- read by editDestination/addDestination
  int? _editing;

  /// The edit pencil beside an account.
  ///
  /// The number is asked for again, not prefilled: only its last four digits
  /// are kept here — the rest went to the provider and was never stored —
  /// and saving four digits as an account number is how a payout goes
  /// nowhere. The bank and the name are filled, so only the digits are
  /// retyped.
  void editDestination(int index) {
    final existing = destinations[index];
    _editing = index;
    bank.value = existing.bank;
    accountNumber.clear();
    accountName.text = existing.accountName;
    touchBank();
    Get.toNamed(AppRoutes.expertBankDetails);
  }

  /// "+ Add New Payout Method", and the first trip through the form. Clears
  /// whatever the last edit left behind.
  void addDestination() {
    _editing = null;
    bank.value = '';
    accountNumber.clear();
    accountName.clear();
    touchBank();
    Get.toNamed(AppRoutes.expertBankDetails);
  }

  /// Sends the account to the provider, which confirms the name on it and
  /// makes a destination of it. Only then is the confirmation shown.
  ///
  /// The number itself is not kept here or on our server: it goes once, and
  /// what comes back is the last four digits.
  Future<void> saveBankDetails() async {
    if (!canSaveBank || saving.value) return;
    saving.value = true;
    final added = await _dashboard.addDestination(
      bankName: bank.value,
      bankCode: _chosenBankCode,
      accountNumber: accountNumber.text.trim(),
    );
    saving.value = false;
    if (!added) return;

    _editing = null;
    accountNumber.clear();
    Get.toNamed(
      AppRoutes.expertPayoutOutcome,
      arguments: PayoutOutcome.methodUpdated,
    );
  }

  /// Whether a request is in flight, so neither button can be pressed twice.
  final RxBool saving = false.obs;

  /// Where Withdraw on the Earnings card goes.
  ///
  /// With nothing on file the money has nowhere to land, so the first trip
  /// is through the payout-method chooser; afterwards it is straight to the
  /// amount, which lists the accounts as destinations.
  void startWithdrawal() => Get.toNamed(
        hasDestination ? AppRoutes.expertWithdraw : AppRoutes.expertPayoutMethod,
      );

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

  /// Bank Transfer has a form behind it; the other two have no frame of
  /// their own and nothing at the provider, so they still say so rather than
  /// pretending.
  void proceed() {
    if (method.value == PayoutMethod.bankTransfer) {
      addDestination();
      return;
    }
    AppFeedback.info(
      'Paying out through ${method.value.label} is not built yet.',
    );
  }

  /// The Withdraw button on the amount screen.
  ///
  /// The request is recorded; the money is sent by a person afterwards. The
  /// outcome screen says a withdrawal is on its way, which is what has
  /// actually happened — and nothing claims it has landed.
  Future<void> withdraw() async {
    if (!canProceed || !hasDestination || saving.value) return;
    saving.value = true;
    final asked = await _dashboard.requestPayout(requested);
    saving.value = false;
    if (!asked) return;

    Get.toNamed(
      AppRoutes.expertPayoutOutcome,
      arguments: PayoutOutcome.withdrawalSent,
    );
  }
}
