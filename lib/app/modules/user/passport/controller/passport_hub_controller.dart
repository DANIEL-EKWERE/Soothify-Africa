import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/checkout.dart';
import '../../../../data/models/passport_reservation.dart';
import '../../../../data/repositories/billing_repository.dart';
import '../../../../data/repositories/spaces_repository.dart';

/// The Passport Hub — the Plans tab once a Passport is active.
///
/// Holds the two things the screen draws: what the membership allows, and
/// what the member has booked against it. They come from different places —
/// the allowance from billing, the reservations from spaces — and both have
/// to land before the balance and the list agree with each other, so they
/// are fetched together.
class PassportHubController extends BaseController {
  PassportHubController(this._billing, this._spaces);

  final BillingRepository _billing;
  final SpacesRepository _spaces;

  final Rx<MembershipStatus> membership = MembershipStatus.none.obs;
  final RxList<PassportReservation> reservations =
      <PassportReservation>[].obs;

  /// Which reservation is being given back, so only its own row spins.
  final RxnInt cancelling = RxnInt();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  /// Why the reservations list failed, when it did. Null when it did not.
  final RxnString listError = RxnString();

  Future<void> load() => guard(() async {
        // Started together but failed apart. They were awaited as one pair,
        // which meant a failing reservations call left the plan unread --
        // and `MembershipStatus.none` draws as a perfectly plausible
        // "Soothify Passport · Active · ₦0/month · 0 of 0 remaining", which
        // is a lie about something somebody paid for. A plan that cannot be
        // read is worth saying out loud; a plan that can should be shown
        // whatever the list does.
        final plan = _billing.membership();
        final list = _spaces.reservations();

        listError.value = null;
        try {
          reservations.assignAll(await list);
        } on AppException catch (failure) {
          reservations.clear();
          listError.value = failure.message;
        }

        // Last, and unguarded: this one failing is worth the screen's own
        // error state rather than a card full of zeroes.
        membership.value = await plan;
      });

  /// "4 of 6 remaining", as the card prints it.
  String get balanceLabel =>
      '${membership.value.passportRemaining} of '
      '${membership.value.passportTotal} remaining';

  bool get hasReservations => reservations.isNotEmpty;

  void openReservation(PassportReservation held) =>
      Get.toNamed(AppRoutes.passportReservation, arguments: held);

  Future<void> openCancel(PassportReservation held) async {
    final cancelled = await Get.toNamed(
      AppRoutes.passportCancel,
      arguments: held,
    );
    // The cancel screen answers with the reservation it gave back. Reloading
    // rather than removing it locally: the allowance moved too, and that
    // figure is the server's to state.
    if (cancelled == true) await load();
  }

  /// "Manage Passport" — the subscription screen the rest of billing uses.
  void manage() => Get.toNamed(AppRoutes.manageSubscription);
}
