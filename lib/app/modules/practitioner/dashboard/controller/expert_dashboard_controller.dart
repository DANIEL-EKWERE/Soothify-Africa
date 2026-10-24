import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/bank_destination.dart';
import '../../../../data/models/bank_option.dart';
import '../../../../data/models/expert_earnings.dart';
import '../../../../data/models/expert_session.dart';
import '../../../../data/models/expert_tab.dart';
import '../../../../data/repositories/expert_repository.dart';
import '../../shell/controller/expert_shell_controller.dart';

/// Backs every tab of the expert role.
///
/// One controller rather than five: the dashboard, Schedule, Earnings and
/// Notes all read the same two lists, and splitting them would mean fetching
/// the same sessions four times and letting the copies drift.
class ExpertDashboardController extends BaseController {
  ExpertDashboardController(this._repository, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final ExpertRepository _repository;
  final DateTime Function() _now;

  final RxString name = ''.obs;
  final RxList<ExpertSession> sessions = <ExpertSession>[].obs;
  final Rxn<ExpertEarnings> earnings = Rxn<ExpertEarnings>();
  final RxList<AvailabilitySlot> slots = <AvailabilitySlot>[].obs;

  /// The accounts payouts can land in.
  ///
  /// Kept here rather than on [PayoutController] because the payout screens
  /// are bound per route: the controller behind them is disposed when the
  /// last of them is popped, and an account added on the way through has to
  /// outlive that.
  final RxList<BankDestination> destinations = <BankDestination>[].obs;

  DateTime get now => _now();

  /// The dashboard previews three; Schedule lists them all.
  List<ExpertSession> get preview => sessions.take(3).toList();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
        final results = await Future.wait([
          _repository.displayName(),
          _repository.upcomingSessions(),
          _repository.earnings(),
          _repository.availability(),
          _repository.payoutDestinations(),
        ]);
        name.value = results[0] as String;
        sessions.assignAll(results[1] as List<ExpertSession>);
        earnings.value = results[2] as ExpertEarnings;
        slots.assignAll(results[3] as List<AvailabilitySlot>);
        destinations.assignAll(results[4] as List<BankDestination>);
      });

  /// Adds a destination, or overwrites the one being edited.
  ///
  /// Local only: nothing persists payout accounts yet, and writing them to
  /// preferences would put an account number on the device in clear.
  void seeAllSessions() =>
      Get.find<ExpertShellController>().show(ExpertTab.schedule);

  void openEarnings() =>
      Get.find<ExpertShellController>().show(ExpertTab.earnings);

  void openAvailability() => Get.toNamed(AppRoutes.expertAvailability);

  /// Opens or closes an hour to booking.
  ///
  /// Closing it removes it at the server: an hour nobody can book is an
  /// hour that is not there, and the client's calendar reads the same list.
  /// The switch moves first so the screen answers the press, and moves back
  /// if the server refuses — an hour somebody has already booked cannot be
  /// taken away from them.
  Future<void> toggleSlot(AvailabilitySlot slot) async {
    final i = slots.indexWhere((s) => s.id == slot.id);
    if (i < 0) return;

    final closing = slot.enabled;
    slots[i] = slot.copyWith(enabled: !closing);

    final done = await guard(
      () async {
        if (closing) {
          await _repository.removeAvailability(slot.id);
        } else {
          final reopened = await _repository.addAvailability(
            day: slot.day,
            from: slot.from,
            to: slot.to,
          );
          // The reopened hour is a new row with a new id; keeping the old
          // one would make the next close fail.
          final at = slots.indexWhere((s) => s.id == slot.id);
          if (at >= 0) slots[at] = reopened;
        }
        return true;
      },
      onError: (_) {
        final at = slots.indexWhere((s) => s.id == slot.id);
        if (at >= 0) slots[at] = slot;
      },
    );
    if (done != true) return;
  }

  /// Replaces one bookable hour with the hours a repeat covers.
  ///
  /// Closing comes first and is allowed to fail: the server refuses to close
  /// an hour somebody has booked, and that refusal has to stop the rest —
  /// otherwise the old hour stays, the new ones appear, and the
  /// practitioner is bookable twice over.
  /// Opens hours that did not exist before.
  ///
  /// The same write as [rewriteSlot] without the close: a practitioner
  /// with no hours yet has nothing to replace, and until this existed the
  /// editor could only ever edit, so Update Availability was a screen with
  /// no way out of being empty.
  Future<bool> addSlots({
    required List<DateTime> days,
    required int from,
    required int to,
  }) async {
    final opened = await guard(() async {
      final made = <AvailabilitySlot>[];
      for (final day in days) {
        made.add(await _repository.addAvailability(
          day: day,
          from: from,
          to: to,
        ));
      }
      return made;
    });
    if (opened == null) return false;

    slots
      ..addAll(opened)
      ..sort((a, b) {
        final byDay = a.day.compareTo(b.day);
        return byDay != 0 ? byDay : a.from.compareTo(b.from);
      });
    return true;
  }

  Future<bool> rewriteSlot({
    required AvailabilitySlot closing,
    required List<DateTime> days,
    required int from,
    required int to,
  }) async {
    final done = await guard(() async {
      await _repository.removeAvailability(closing.id);
      final opened = <AvailabilitySlot>[];
      for (final day in days) {
        opened.add(await _repository.addAvailability(
          day: day,
          from: from,
          to: to,
        ));
      }
      return opened;
    });
    if (done == null) return false;

    slots
      ..removeWhere((slot) => slot.id == closing.id)
      ..addAll(done)
      ..sort((a, b) {
        final byDay = a.day.compareTo(b.day);
        return byDay != 0 ? byDay : a.from.compareTo(b.from);
      });
    return true;
  }

  /// The banks a payout account can be at, from the provider.
  Future<List<BankOption>> banks() async {
    final found = await guard(
      () => _repository.banks(),
      // The form falls back to an empty picker and says nothing; a snackbar
      // over a form somebody is filling in is noise.
      showFeedback: false,
    );
    return found ?? const [];
  }

  /// Asks to be paid, and says only what is true: the request is in.
  Future<bool> requestPayout(int naira) async {
    final done = await guard(() async {
      await _repository.requestPayout(naira);
      return true;
    });
    if (done != true) return false;

    // The balance moves when the money is actually sent, which is a person's
    // decision, so the figures are read again rather than adjusted here.
    final fresh = await guard(() => _repository.earnings(), showFeedback: false);
    if (fresh != null) earnings.value = fresh;
    return true;
  }

  /// Adds an account payouts can land in, through the provider -- which is
  /// also what confirms the name on it.
  Future<bool> addDestination({
    required String bankName,
    required String bankCode,
    required String accountNumber,
  }) async {
    final added = await guard(() => _repository.addPayoutDestination(
          bankName: bankName,
          bankCode: bankCode,
          accountNumber: accountNumber,
        ));
    if (added == null) return false;

    // Newest first, and the default: that is what the server just made it.
    destinations.insert(0, added);
    return true;
  }

  /// The Quick Action, and the Notes tab's rows. Notes are written per
  /// session, so one has to be chosen first — the frame is titled "Dami's
  /// session notes".
  void openNotes(ExpertSession session) =>
      Get.toNamed(AppRoutes.expertSessionNotes, arguments: session);

  void openSessionNotes() {
    if (sessions.isEmpty) return;
    openNotes(sessions.first);
  }

  /// The pre-call screen — `259:59996`. No call service is wired behind it
  /// on either side; the screen is the connecting state the design draws.
  void joinCall(ExpertSession session) =>
      Get.toNamed(AppRoutes.expertJoinSession, arguments: session);

  /// The bell. A note here used to claim the expert `Notification` frame was
  /// a client screen filed in the wrong row, read off its nav bar; the live
  /// file draws it with the expert's own bar, so it is this role's.
  void openNotifications() => Get.toNamed(AppRoutes.expertNotifications);
}
