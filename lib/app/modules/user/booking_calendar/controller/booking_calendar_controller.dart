import 'package:intl/intl.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/booked_session.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../../data/models/session_mode.dart';
import '../../../../data/models/session_offering.dart';

/// Picking the day the paid-for session actually happens — Figma
/// "Matched with instructor/calendar sc" (`280:26019` in the current file).
///
/// This step existed in the design all along and had never been built: the
/// receipt's "Continue" went back to `AppRoutes.booking`, which starts at the
/// matching interstitial, so paying dropped the user back on "Awesome! You
/// matched with" and the booking was never made.
///
/// The frame itself could not be read — all three Figma budgets were spent —
/// so the layout here follows the sheet this replaces (`ScheduleSheet`) at
/// full-screen size. Worth re-measuring against `280:26019`.
class BookingCalendarController extends BaseController {
  BookingCalendarController(this._bookings, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final BookingRepository _bookings;

  final DateTime Function() _now;

  /// Both shapes: a bare offering is what the older callers pass.
  late final SessionOffering offering = switch (Get.arguments) {
    final CalendarArguments given => given.offering,
    final SessionOffering only => only,
    _ => SessionOffering.therapy,
  };

  late final Rx<DateTime> month = DateTime(_now().year, _now().month).obs;

  final Rxn<DateTime> selected = Rxn<DateTime>();

  /// The hours offered for the chosen day.
  ///
  /// Read from the expert's own availability rather than a fixed list: an
  /// hour somebody else has already booked must not be offered, and only
  /// the server knows which those are.
  final RxList<FreeSlot> available = <FreeSlot>[].obs;

  /// Every free hour the expert has, across the days the calendar shows.
  final RxList<FreeSlot> _allSlots = <FreeSlot>[].obs;

  /// Which hours the chosen day leaves, as the buttons print them.
  List<String> get slots =>
      available.map((slot) => slot.label).toList(growable: false);

  /// Who the client was matched with, if matching ran before this screen.
  final Rxn<MatchedExpert> expert = Rxn<MatchedExpert>();

  final RxnString slot = RxnString();

  bool get canConfirm => selected.value != null && slot.value != null;

  String get monthLabel => DateFormat('MMMM yyyy').format(month.value);

  String get summary {
    final day = selected.value;
    if (day == null) return '';
    return '${DateFormat('EEEE, d MMMM').format(day)} at ${slot.value}';
  }

  @override
  void onInit() {
    super.onInit();
    _loadAvailability();
  }

  /// Ask who is free, then for what hours. Both in one go, because the
  /// calendar cannot offer anything until it knows.
  Future<void> _loadAvailability() async {
    await guard(() async {
      // Matched again here rather than carried: `matching.best` is
      // deterministic for a discipline, so this is the same person the
      // screen before named. There is no lookup by id to use instead.
      final matched = await _bookings.match(discipline: _discipline);
      expert.value = matched;
      if (matched == null) {
        _allSlots.clear();
        available.clear();
        return;
      }

      final from = _now();
      _allSlots.value = await _bookings.freeSlots(
        matched.id,
        from: from,
        to: from.add(const Duration(days: 60)),
      );
      // Open on the first day with hours left, so the screen arrives with
      // something to choose rather than an empty strip under the grid. The
      // month follows, or the chosen day would be off-screen.
      if (selected.value == null && _allSlots.isNotEmpty) {
        final first = _allSlots.first.day;
        selected.value = first;
        month.value = DateTime(first.year, first.month);
      }
      _narrowToSelectedDay();
    });
  }

  /// The app's sections do not map one-to-one onto what an expert is booked
  /// for: Pilates & Core and Stretch & Restore are both movement, and the
  /// server knows yoga and pilates by name.
  /// On the enum, so this screen and the matched one cannot drift: they
  /// did, and the matched screen asked for a discipline the server has
  /// never heard of.
  String get _discipline => offering.wire;

  bool hasSlotsOn(DateTime day) => _allSlots.any((s) => _sameDay(s.day, day));

  void pickDay(DateTime day) {
    selected.value = day;
    // A day's hours are its own; keeping a time chosen on another day would
    // book something nobody picked.
    slot.value = null;
    _narrowToSelectedDay();
  }

  void _narrowToSelectedDay() {
    final day = selected.value;
    available.value = day == null
        ? const []
        : _allSlots.where((s) => _sameDay(s.day, day)).toList();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void pickSlot(String value) => slot.value = value;

  void previousMonth() =>
      month.value = DateTime(month.value.year, month.value.month - 1);

  void nextMonth() =>
      month.value = DateTime(month.value.year, month.value.month + 1);

  /// Hold the hour, then go and pay for it.
  ///
  /// The booking is made here rather than after payment: the server holds
  /// the slot for twenty minutes so nobody else takes it while the card is
  /// being typed, and releases it if the payment never comes.
  ///
  /// `offNamed`, so the receipt's Continue cannot step back onto a calendar
  /// offering to book the session a second time.
  /// [mode] is supplied by a test, which has no navigator to show the
  /// picker on. The app leaves it out and the picker is opened.
  Future<void> confirm({SessionMode? mode}) async {
    if (!canConfirm || isLoading.value) return;

    final chosen = available.firstWhereOrNull((s) => s.label == slot.value);
    if (chosen == null) return;

    // How they want to take it, before the hour is held. The session
    // carries this, and until now nothing asked: every booking was sent
    // as a video call whatever the questionnaire had been told.
    // Typed, not inferred: `Get.toNamed` answers `dynamic`, and Dart does
    // not promote a dynamic through an `is!` check.
    final Object? callMode = mode ??
        await Get.toNamed<dynamic>(
          AppRoutes.sessionMode,
          arguments: SessionMode.fromWire(
          PrefUtils.isReady ? PrefUtils().sessionMode() : '',
        ),
        );
    if (callMode is! SessionMode) return;  // backed out; nothing is booked

    // Remembering the choice is a convenience; failing to remember it must
    // not stop the booking.
    if (PrefUtils.isReady) {
      await PrefUtils().setSessionMode(callMode.wire);
    }

    final session = await guard(() => _bookings.book(
          discipline: _discipline,
          day: selected.value!,
          startMinute: chosen.startMinute,
          expertId: expert.value?.id,
          mode: callMode.wire,
        ));
    // guard has already said what went wrong -- the hour taken a moment ago
    // by somebody else, most often.
    if (session == null) {
      await _loadAvailability();
      return;
    }

    Get.offNamed(AppRoutes.bookingPayment, arguments: session);
  }
}
