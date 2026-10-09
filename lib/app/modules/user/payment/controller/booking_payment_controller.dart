import 'package:intl/intl.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/booked_slot.dart';
import '../../../../data/models/coach.dart';
import '../../../../data/models/session_offering.dart';

/// Backs the booking payment screen and its receipt — Figma "Therapist
/// booking payment" (`259:58862`), "Pilates booking paymet" (`259:58919`)
/// and "Yoga booking paymet" (`259:58941`).
///
/// The last two are pixel-identical; the therapist frame differs only in its
/// prices and in spelling the cancellation policy out. So one screen serves
/// all three, taking the [SessionOffering].
class BookingPaymentController extends GetxController {
  BookingPaymentController(this.offering, {this.booked});

  final SessionOffering offering;

  /// When the session runs, chosen on the calendar before this screen. Null
  /// only on the older entry points that open payment without a time.
  final BookedSlot? booked;

  /// The frames draw Monthly Plan filled and Single Session outlined, which
  /// is the selected state — so Monthly is where the screen opens.
  final Rx<SessionPlan> plan = SessionPlan.monthly.obs;

  /// Whose session this is. The frames print the literal placeholder
  /// "[Expert Name]"; the matched coach is who actually goes there.
  /// The heading greets the expert by first name — "Ready for your session
  /// with Baraqhat" — which is what keeps it on one line.
  String get expertName => Coach.sample.name.split(' ').first;

  void select(SessionPlan value) => plan.value = value;

  int get amount => switch (plan.value) {
        SessionPlan.single => offering.single,
        SessionPlan.monthly => offering.monthly,
      };

  /// The frames print a bare figure — "25,000" — with no currency mark at
  /// all. A price on a payment screen that does not say what it is in is a
  /// hazard, so the naira sign is added here. It is this app's addition, not
  /// the design's.
  static String money(int naira) =>
      '₦${NumberFormat.decimalPattern('en').format(naira)}';

  /// No payment provider is wired. Rather than claim a charge went through,
  /// this goes to the receipt the design draws and says nothing about money
  /// having moved.
  /// On to "Confirm booking" — the Care Guarantee and the totals — which is
  /// where the payment is actually started.
  ///
  /// That screen was built and never reached: this used to jump straight to
  /// the receipt, so nobody ever saw what they were agreeing to. The chosen
  /// time travels along, since the confirmation at the end names it.
  void proceed() => Get.toNamed(
        AppRoutes.confirmBooking,
        arguments: booked ?? offering,
      );

  /// "Continue" on the receipt — the confirmation, and the end of the chain.
  ///
  /// The calendar now runs before payment, so by here the session has a time
  /// and has been paid for; there is nothing left to choose.
  void done() =>
      Get.offNamed(AppRoutes.bookingConfirmed, arguments: booked);

  /// The policy panel summarises; `280:26738` spells it out.
  void openPolicy() => Get.toNamed(AppRoutes.cancellationPolicy);
}
