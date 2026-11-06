import '../../../core/app_export.dart';
import '../../../core/base_controller.dart';
import '../../../data/models/studio_partner.dart';
import '../../../data/repositories/partner_repository.dart';

/// Which half of the portal is showing — the frames are one screen with two
/// tabs, not two screens.
enum PartnerTab { overview, guests }

/// The attendance chips over the guest list.
enum GuestFilter { all, checkedIn, awaiting }

/// Backs the Studio Partner portal — Figma `4968:32935` (Overview) and
/// `4968:32751` (Active Guest List).
class PartnerController extends BaseController {
  PartnerController(this._repository);

  final PartnerRepository _repository;

  final Rx<PartnerTab> tab = PartnerTab.overview.obs;
  final Rxn<StudioOverview> overview = Rxn<StudioOverview>();
  final RxList<StudioBookingRequest> requests = <StudioBookingRequest>[].obs;
  final RxList<StudioGuest> guests = <StudioGuest>[].obs;

  final Rx<GuestFilter> filter = GuestFilter.all.obs;
  final RxString query = ''.obs;

  /// Which request or guest is mid-answer, so only its own row spins.
  final RxnString busyId = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
        final results = await Future.wait([
          _repository.overview(),
          _repository.requests(),
          _repository.guests(),
        ]);
        overview.value = results[0] as StudioOverview;
        requests.assignAll(results[1] as List<StudioBookingRequest>);
        guests.assignAll(results[2] as List<StudioGuest>);
      });

  void show(PartnerTab value) => tab.value = value;

  /// Only what still needs answering. An accepted request leaves the feed —
  /// the frame's own summary counts "requests that need your attention".
  List<StudioBookingRequest> get pending => requests
      .where((r) => r.status == StudioRequestStatus.pending)
      .toList();

  String get feedSummary {
    final n = pending.length;
    return n == 1
        ? '1 request needs your attention today.'
        : '$n requests need your attention today.';
  }

  int get checkedIn =>
      guests.where((g) => g.arrival == StudioArrival.checkedIn).length;

  int get awaiting => guests.length - checkedIn;

  /// The list under the chips, narrowed by the chip and the search box.
  List<StudioGuest> get visibleGuests {
    final term = query.value.trim().toLowerCase();
    return guests.where((g) {
      final matchesFilter = switch (filter.value) {
        GuestFilter.all => true,
        GuestFilter.checkedIn => g.arrival == StudioArrival.checkedIn,
        GuestFilter.awaiting => g.arrival == StudioArrival.awaiting,
      };
      if (!matchesFilter) return false;
      if (term.isEmpty) return true;
      // The placeholder offers both: "Search by guest name or booking ID".
      return g.name.toLowerCase().contains(term) ||
          g.code.toLowerCase().contains(term);
    }).toList();
  }

  String get listSummary =>
      'All ${guests.length} confirmed guests shown · $checkedIn checked in';

  void choose(GuestFilter value) => filter.value = value;

  void search(String value) => query.value = value;

  Future<void> accept(StudioBookingRequest request) =>
      _answer(request, accepting: true);

  Future<void> decline(StudioBookingRequest request) =>
      _answer(request, accepting: false);

  Future<void> _answer(
    StudioBookingRequest request, {
    required bool accepting,
  }) async {
    if (busyId.value != null) return;
    busyId.value = request.id;
    final answered = await guard(
      () => accepting
          ? _repository.accept(request.id)
          : _repository.decline(request.id),
      setLoading: false,
    );
    busyId.value = null;
    if (answered == null) return;

    final i = requests.indexWhere((r) => r.id == request.id);
    if (i >= 0) requests[i] = answered;
    // The floor is committed, so the counts above move with it.
    await guard(() async => overview.value = await _repository.overview(),
        showFeedback: false, setLoading: false);
    AppFeedback.info(
      accepting
          ? '${request.guestName} is booked for ${request.className}.'
          : 'Declined. ${request.guestName} will be offered another studio.',
    );
  }

  /// The door scanned a QR, or pressed the row to admit someone by hand.
  Future<void> checkIn(StudioGuest guest) async {
    if (guest.arrival == StudioArrival.checkedIn || busyId.value != null) {
      return;
    }
    busyId.value = guest.id;
    final done = await guard(
      () => _repository.checkIn(guest.id, code: guest.code),
      setLoading: false,
    );
    busyId.value = null;
    if (done == null) return;
    final i = guests.indexWhere((g) => g.id == guest.id);
    if (i >= 0) guests[i] = done;
  }
}
