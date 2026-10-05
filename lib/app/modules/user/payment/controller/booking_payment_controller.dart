import 'package:intl/intl.dart';

import '../../../../core/app_export.dart';
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
  BookingPaymentController(this.offering);

  final SessionOffering offering;

  /// The frames draw Monthly Plan filled and Single Session outlined, which
  /// is the selected state — so Monthly is where the screen opens.
  final Rx<SessionPlan> plan = SessionPlan.monthly.obs;

  /// Whose session this is. The frames print the literal placeholder
  /// "[Expert Name]"; the matched coach is who actually goes there.
  String get expertName => Coach.sample.name;

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

  /// "Proceed to Payment" — on to "Confirm booking" (`280:26699`), where the
  /// care guarantee and the total are shown before paying.
  void proceed() => Get.toNamed(AppRoutes.careGuarantee, arguments: offering);

  /// "Pay with Paystack". No payment provider is wired yet. Rather than claim
  /// a charge went through, this goes to the receipt the design draws and
  /// says nothing about money having moved.
  void pay() => Get.toNamed(AppRoutes.paymentSuccess, arguments: offering);

  /// "Continue" on the receipt — back into the booking flow the payment
  /// unlocks, replacing the receipt so it cannot be returned to.
  ///
  /// Carries the offering: the matching interstitial names the discipline
  /// ("Finding your Pilates instructor"), and it is the only thing that
  /// knows which one was booked.
  void done() => Get.offNamed(AppRoutes.booking, arguments: offering);

  /// The policy panel summarises; `280:26738` spells it out.
  void openPolicy() => Get.toNamed(AppRoutes.cancellationPolicy);
}
