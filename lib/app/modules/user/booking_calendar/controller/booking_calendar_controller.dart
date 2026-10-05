import 'package:intl/intl.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/booked_slot.dart';
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
class BookingCalendarController extends GetxController {
  BookingCalendarController({DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  late final SessionOffering offering = Get.arguments is SessionOffering
      ? Get.arguments as SessionOffering
      : SessionOffering.therapy;

  late final Rx<DateTime> month = DateTime(_now().year, _now().month).obs;

  final Rxn<DateTime> selected = Rxn<DateTime>();

  /// The slots the session can start at. The frame was unreadable, so these
  /// are a plain working day rather than anything measured.
  static const List<String> slots = [
    '9:00am',
    '11:00am',
    '1:00pm',
    '3:00pm',
    '5:00pm',
    '7:00pm',
  ];

  final RxnString slot = RxnString();

  bool get canConfirm => selected.value != null && slot.value != null;

  String get monthLabel => DateFormat('MMMM yyyy').format(month.value);

  String get summary {
    final day = selected.value;
    if (day == null) return '';
    return '${DateFormat('EEEE, d MMMM').format(day)} at ${slot.value}';
  }

  void pickDay(DateTime day) => selected.value = day;

  void pickSlot(String value) => slot.value = value;

  void previousMonth() =>
      month.value = DateTime(month.value.year, month.value.month - 1);

  void nextMonth() =>
      month.value = DateTime(month.value.year, month.value.month + 1);

  /// On to the payment screen, with the chosen time attached.
  ///
  /// `offNamed`, so the receipt's Continue cannot step back onto a calendar
  /// offering to book the session a second time.
  void confirm() {
    if (!canConfirm) return;
    Get.offNamed(
      AppRoutes.bookingPayment,
      arguments: BookedSlot(
        offering: offering,
        day: selected.value!,
        slot: slot.value!,
      ),
    );
  }
}
