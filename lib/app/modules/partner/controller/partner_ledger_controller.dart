import '../../../core/app_export.dart';
import '../../../core/base_controller.dart';
import '../../../data/models/studio_partner.dart';
import '../../../data/repositories/partner_repository.dart';
import '../../../widgets/confirm_dialog.dart';

/// Backs "4.2 · Studio payout ledger" (`416:26282`).
class PartnerLedgerController extends BaseController {
  PartnerLedgerController(this._repository);

  final PartnerRepository _repository;

  final Rxn<StudioLedger> ledger = Rxn<StudioLedger>();

  /// Which line is being disputed, so only its own button spins.
  final RxnString busyId = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() =>
      guard(() async => ledger.value = await _repository.ledger());

  /// "Dispute Check-In". Confirmed first: it takes money out of the
  /// studio's next settlement while somebody looks at it, which is not
  /// something to do on a mis-tap.
  Future<void> dispute(StudioEarning earning) async {
    if (busyId.value != null) return;
    final sure = await Get.dialog<bool>(
      ConfirmDialog(
        title: 'Dispute this check-in?',
        message:
            '${earning.guestName}’s ${earning.category} session on '
            '${earning.earnedOn.day}/${earning.earnedOn.month} will be held '
            'back from your next settlement while we look into it.',
        confirmLabel: 'Dispute',
      ),
    );
    if (sure != true) return;

    busyId.value = earning.id;
    final answered = await guard(
      () => _repository.dispute(earning.id),
      setLoading: false,
    );
    busyId.value = null;
    if (answered == null) return;

    final rows = [...?ledger.value?.earnings];
    final i = rows.indexWhere((e) => e.id == earning.id);
    if (i >= 0) rows[i] = answered;
    final was = ledger.value;
    if (was != null) {
      ledger.value = StudioLedger(
        accruedNaira: was.accruedNaira,
        nextDisbursement: was.nextDisbursement,
        lifetimeNaira: was.lifetimeNaira,
        period: was.period,
        totalEarnings: was.totalEarnings,
        earnings: rows,
      );
    }
    AppFeedback.info('We will look into that check-in and come back to you.');
  }
}
